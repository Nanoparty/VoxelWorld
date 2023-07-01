using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using Unity.VisualScripting;
using Unity.VisualScripting.FullSerializer;
using UnityEngine;
using static Blocks;
using static Perlin_Noise_Generation;

public class GPU_Caching : MonoBehaviour
{
    [SerializeField] public int WorldWidth;
    [SerializeField] public int WorldLength;
    [SerializeField] public int WorldHeight;
    [SerializeField] public float WorldScale;

    [SerializeField] public Mesh GrassMesh;
    [SerializeField] public Mesh DirtMesh;
    [SerializeField] public Mesh WaterMesh;
    [SerializeField] public Mesh SandMesh;
    [SerializeField] public Mesh StoneMesh;
    [SerializeField] public Mesh SnowMesh;

    [SerializeField] public Material GrassMaterial;
    [SerializeField] public Material DirtMaterial;
    [SerializeField] public Material WaterMaterial;
    [SerializeField] public Material SnowMaterial;
    [SerializeField] public Material StoneMaterial;
    [SerializeField] public Material SandMaterial;

    private List<List<Matrix4x4>> GrassBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> DirtBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> WaterBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> SandBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> StoneBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> SnowBatches = new List<List<Matrix4x4>>();

    private BlockType[,,] _world;

    private int _totalBlocks;

    private Perlin_Noise_Generation _perlin_generator;

    private WorldData data;

    //public int instanceCount = 10000;
    public Mesh instanceMesh;
    public Material instanceMaterial;
    public int subMeshIndex = 0;

    private int cachedInstanceCount = -1;
    private int cachedSubMeshIndex = -1;
    private ComputeBuffer positionBuffer;
    private ComputeBuffer argsBuffer;
    private uint[] args = new uint[5] { 0, 0, 0, 0, 0 };

    
    private void Start()
    {
        _perlin_generator = new Perlin_Noise_Generation(WorldWidth, WorldLength, WorldHeight, WorldScale);

        data = _perlin_generator.GenerateWorldData(new Vector2(Random.Range(0, 1000), Random.Range(0, 1000)));
        _world = data._world;

        argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        UpdateBuffers();

    }

    private void Update()
    {
        Graphics.DrawMeshInstancedIndirect(instanceMesh, subMeshIndex, instanceMaterial, new Bounds(Vector3.zero, new Vector3(100.0f, 100.0f, 100.0f)), argsBuffer);
    }

    private void UpdateBuffers()
    {
        if (instanceMesh != null)
        {
            subMeshIndex = Mathf.Clamp(subMeshIndex, 0, instanceMesh.subMeshCount - 1);
        }

        if (positionBuffer != null)
        {
            positionBuffer.Release();
        }

        positionBuffer = new ComputeBuffer(WorldWidth * WorldLength * WorldHeight, 16);
        Vector4[] positions = new Vector4[WorldWidth * WorldLength * WorldHeight];
        List<Vector4> positions2 = new List<Vector4>();

        for (int pos = 0; pos < positions.Length; pos++)
        {
            int y = pos / (WorldWidth * WorldLength);

            int z = pos / WorldWidth - (y * WorldWidth);

            int x = pos % WorldWidth;



            positions[pos] = new Vector4(x, y, z, 1);
            positions2.Add(new Vector4(x, y, z, 1));
        }

        positionBuffer.SetData(positions);
        instanceMaterial.SetBuffer("positionBuffer", positionBuffer);

        if (instanceMesh != null)
        {
            args[0] = (uint)instanceMesh.GetIndexCount(subMeshIndex);
            args[1] = (uint)(WorldHeight * WorldLength * WorldWidth);
            args[2] = (uint)instanceMesh.GetIndexStart(subMeshIndex);
            args[3] = (uint)instanceMesh.GetBaseVertex(subMeshIndex);
        }
        else
        {
            args[0] = args[1] = args[2] = args[3] = 0;
        }
        argsBuffer.SetData(args);
        cachedInstanceCount = (WorldHeight * WorldLength * WorldWidth);
        cachedSubMeshIndex = subMeshIndex;
    }

    void OnDisable()
    {
        if (positionBuffer != null)
            positionBuffer.Release();
        positionBuffer = null;

        if (argsBuffer != null)
            argsBuffer.Release();
        argsBuffer = null;
    }

    private void GenerateBatches()
    {
        int grassBlocks = 0;
        int dirtBlocks = 0;
        int waterBlocks = 0;
        int sandBlocks = 0;
        int stoneBlocks = 0;
        int snowBlocks = 0;

        GrassBatches.Add(new List<Matrix4x4>());
        DirtBatches.Add(new List<Matrix4x4>());
        SandBatches.Add(new List<Matrix4x4>());
        WaterBatches.Add(new List<Matrix4x4>());
        StoneBatches.Add(new List<Matrix4x4>());
        SnowBatches.Add(new List<Matrix4x4>());

        for (int i = 0; i < WorldWidth; i++)
        {
            for (int j = 0; j < WorldLength; j++)
            {
                for (int k = 0; k < WorldHeight; k++)
                {
                    if (_world[i, j, k] == BlockType.GRASS)
                    {
                        if (!Visible(i, j, k))
                            continue;

                        if (grassBlocks < 1000)
                        {
                            GrassBatches[GrassBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                            grassBlocks++;
                        }
                        else
                        {
                            GrassBatches.Add(new List<Matrix4x4>());
                            GrassBatches[GrassBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                            grassBlocks = 1;
                        }
                    }
                    if (_world[i, j, k] == BlockType.DIRT)
                    {
                        if (!Visible(i, j, k))
                            continue;

                        if (dirtBlocks < 1000)
                        {
                            DirtBatches[DirtBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                            dirtBlocks++;
                        }
                        else
                        {
                            DirtBatches.Add(new List<Matrix4x4>());
                            DirtBatches[DirtBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                            dirtBlocks = 1;
                        }
                    }
                    if (_world[i, j, k] == BlockType.SAND)
                    {
                        if (!Visible(i, j, k))
                            continue;

                        if (sandBlocks < 1000)
                        {
                            SandBatches[SandBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                            sandBlocks++;
                        }
                        else
                        {
                            SandBatches.Add(new List<Matrix4x4>());
                            SandBatches[SandBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                            sandBlocks = 1;
                        }
                    }
                    if (_world[i, j, k] == BlockType.WATER)
                    {
                        if (!Visible(i, j, k))
                            continue;

                        if (waterBlocks < 1000)
                        {
                            WaterBatches[WaterBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                            waterBlocks++;
                        }
                        else
                        {
                            WaterBatches.Add(new List<Matrix4x4>());
                            WaterBatches[WaterBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                            waterBlocks = 1;
                        }
                    }
                    if (_world[i, j, k] == BlockType.STONE)
                    {
                        if (!Visible(i, j, k))
                            continue;

                        if (stoneBlocks < 1000)
                        {
                            StoneBatches[StoneBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                            stoneBlocks++;
                        }
                        else
                        {
                            StoneBatches.Add(new List<Matrix4x4>());
                            StoneBatches[StoneBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                            stoneBlocks = 1;
                        }
                    }
                    if (_world[i, j, k] == BlockType.SNOW)
                    {
                        if (!Visible(i, j, k))
                            continue;

                        if (snowBlocks < 1000)
                        {
                            SnowBatches[SnowBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                            snowBlocks++;
                        }
                        else
                        {
                            SnowBatches.Add(new List<Matrix4x4>());
                            SnowBatches[SnowBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                            snowBlocks = 1;
                        }
                    }
                }
            }
        }
    }

    private void RenderBatches(List<List<Matrix4x4>> Batch, Mesh mesh, Material material)
    {
        foreach (var batch in Batch)
        {
            for (int i = 0; i < mesh.subMeshCount; i++)
            {
                Graphics.DrawMeshInstanced(mesh, i, material, batch);
            }
        }
    }

    private bool Visible(int i, int j, int k)
    {
        if (i == 0 || i == WorldWidth - 1) return true;
        if (j == 0 || j == WorldLength - 1) return true;
        if (k == 0 || k == WorldHeight - 1) return true;

        if (_world[i, j, k] == BlockType.WATER) return true;

        if (_world[i, j, k + 1] == BlockType.AIR || _world[i, j, k - 1] == BlockType.AIR) return true;
        if (_world[i, j + 1, k] == BlockType.AIR || _world[i, j - 1, k] == BlockType.AIR) return true;
        if (_world[i + 1, j, k] == BlockType.AIR || _world[i - 1, j, k] == BlockType.AIR) return true;

        if (_world[i, j, k + 1] == BlockType.WATER || _world[i, j, k - 1] == BlockType.WATER) return true;
        if (_world[i, j + 1, k] == BlockType.WATER || _world[i, j - 1, k] == BlockType.WATER) return true;
        if (_world[i + 1, j, k] == BlockType.WATER || _world[i - 1, j, k] == BlockType.WATER) return true;

        return false;
    }

}
