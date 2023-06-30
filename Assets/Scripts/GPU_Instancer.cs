using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static Blocks;

public class GPU_Instancer : MonoBehaviour
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

    private void Update()
    {
        RenderBatches(GrassBatches, GrassMesh, GrassMaterial);
        RenderBatches(DirtBatches, DirtMesh, DirtMaterial);
        RenderBatches(WaterBatches, WaterMesh, WaterMaterial);
        RenderBatches(SandBatches, SandMesh, SandMaterial);
        RenderBatches(StoneBatches, StoneMesh, StoneMaterial);
        RenderBatches(SnowBatches, SnowMesh, SnowMaterial);
    }

    private void Start()
    {
        _perlin_generator = new Perlin_Noise_Generation(WorldWidth, WorldLength, WorldHeight, WorldScale);

        _world = _perlin_generator.GenerateWorld(new Vector2(Random.Range(0, 1000), Random.Range(0, 1000)));

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
                    if (_world[i,j,k] == BlockType.GRASS)
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
