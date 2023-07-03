using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using TMPro;
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

    private ComputeBuffer grassBuffer;
    private ComputeBuffer dirtBuffer;
    private ComputeBuffer waterBuffer;
    private ComputeBuffer sandBuffer;
    private ComputeBuffer stoneBuffer;
    private ComputeBuffer snowBuffer;

    private ComputeBuffer grassArgs;
    private ComputeBuffer dirtArgs;
    private ComputeBuffer waterArgs;
    private ComputeBuffer sandArgs;
    private ComputeBuffer stoneArgs;
    private ComputeBuffer snowArgs;

    private BlockType[,,] _world;

    private int _totalBlocks;
    private int _renderedBlocks;

    private Perlin_Noise_Generation _perlin_generator;

    private WorldData data;

    public Mesh instanceMesh;
    public Material instanceMaterial;
    public int subMeshIndex = 0;

    private int cachedInstanceCount = -1;
    private int cachedSubMeshIndex = -1;
    private uint[] args1 = new uint[5] { 0, 0, 0, 0, 0 };
    private uint[] args2 = new uint[5] { 0, 0, 0, 0, 0 };
    private uint[] args3 = new uint[5] { 0, 0, 0, 0, 0 };
    private uint[] args4 = new uint[5] { 0, 0, 0, 0, 0 };
    private uint[] args5 = new uint[5] { 0, 0, 0, 0, 0 };
    private uint[] args6 = new uint[5] { 0, 0, 0, 0, 0 };


    private void Start()
    {
        _perlin_generator = new Perlin_Noise_Generation(WorldWidth, WorldLength, WorldHeight, WorldScale);

        data = _perlin_generator.GenerateWorldData(new Vector2(Random.Range(0, 1000), Random.Range(0, 1000)));
        _world = data._world;


        _totalBlocks = data.WaterCount + data.GrassCount + data.SandCount + data.StoneCount + data.SnowCount + data.DirtCount;
        OcclusionCulling();
        _renderedBlocks = data.WaterCount + data.GrassCount + data.SandCount + data.StoneCount + data.SnowCount + data.DirtCount;

        grassArgs = new ComputeBuffer(1, args1.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        dirtArgs = new ComputeBuffer(1, args2.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        sandArgs = new ComputeBuffer(1, args3.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        stoneArgs = new ComputeBuffer(1, args4.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        snowArgs = new ComputeBuffer(1, args5.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        waterArgs = new ComputeBuffer(1, args6.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        UpdateBuffers();

    }

    public void Regenerate()
    {
        _perlin_generator = new Perlin_Noise_Generation(WorldWidth, WorldLength, WorldHeight, WorldScale);

        data = _perlin_generator.GenerateWorldData(new Vector2(Random.Range(0, 1000), Random.Range(0, 1000)));
        _world = data._world;


        _totalBlocks = data.WaterCount + data.GrassCount + data.SandCount + data.StoneCount + data.SnowCount + data.DirtCount;
        OcclusionCulling();
        _renderedBlocks = data.WaterCount + data.GrassCount + data.SandCount + data.StoneCount + data.SnowCount + data.DirtCount;

        grassArgs = new ComputeBuffer(1, args1.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        dirtArgs = new ComputeBuffer(1, args2.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        sandArgs = new ComputeBuffer(1, args3.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        stoneArgs = new ComputeBuffer(1, args4.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        snowArgs = new ComputeBuffer(1, args5.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        waterArgs = new ComputeBuffer(1, args6.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        UpdateBuffers();
    }

    private void Update()
    {
        Graphics.DrawMeshInstancedIndirect(GrassMesh, subMeshIndex, GrassMaterial, new Bounds(new Vector3(WorldWidth / 2, WorldHeight / 2, WorldLength / 2), new Vector3(WorldWidth, WorldHeight, WorldLength)), grassArgs);
        Graphics.DrawMeshInstancedIndirect(DirtMesh, subMeshIndex, DirtMaterial, new Bounds(new Vector3(WorldWidth / 2, WorldHeight / 2, WorldLength / 2), new Vector3(WorldWidth, WorldHeight, WorldLength)), dirtArgs);
        Graphics.DrawMeshInstancedIndirect(SandMesh, subMeshIndex, SandMaterial, new Bounds(new Vector3(WorldWidth / 2, WorldHeight / 2, WorldLength / 2), new Vector3(WorldWidth, WorldHeight, WorldLength)), sandArgs);
        Graphics.DrawMeshInstancedIndirect(StoneMesh, subMeshIndex, StoneMaterial, new Bounds(new Vector3(WorldWidth / 2, WorldHeight / 2, WorldLength / 2), new Vector3(WorldWidth, WorldHeight, WorldLength)), stoneArgs);
        Graphics.DrawMeshInstancedIndirect(SnowMesh, subMeshIndex, SnowMaterial, new Bounds(new Vector3(WorldWidth / 2, WorldHeight / 2, WorldLength / 2), new Vector3(WorldWidth, WorldHeight, WorldLength)), snowArgs);
        Graphics.DrawMeshInstancedIndirect(WaterMesh, subMeshIndex, WaterMaterial, new Bounds(new Vector3(WorldWidth / 2, WorldHeight / 2, WorldLength / 2), new Vector3(WorldWidth, WorldHeight, WorldLength)), waterArgs);
    }

    private void UpdateBuffers()
    {
        if (GrassMesh != null)
        {
            subMeshIndex = Mathf.Clamp(subMeshIndex, 0, GrassMesh.subMeshCount - 1);
        }

        if (grassBuffer != null)
        {
            grassBuffer.Release();
        }     

        grassBuffer = new ComputeBuffer(Mathf.Max(data.GrassCount, 1), 16);
        dirtBuffer = new ComputeBuffer(Mathf.Max(data.DirtCount, 1), 16);
        sandBuffer = new ComputeBuffer(Mathf.Max(data.SandCount, 1), 16);
        stoneBuffer = new ComputeBuffer(Mathf.Max(data.StoneCount, 1), 16);
        snowBuffer = new ComputeBuffer(Mathf.Max(data.SnowCount, 1), 16);
        waterBuffer = new ComputeBuffer(Mathf.Max(data.WaterCount, 1), 16);

        int grassIndex = 0;
        int dirtIndex = 0;
        int sandIndex = 0;
        int snowIndex = 0;
        int stoneIndex = 0;
        int waterIndex = 0;

        Vector4[] grassPositions = new Vector4[data.GrassCount];
        Vector4[] dirtPositions = new Vector4[data.DirtCount];
        Vector4[] sandPositions = new Vector4[data.SandCount];
        Vector4[] stonePositions = new Vector4[data.StoneCount];
        Vector4[] snowPositions = new Vector4[data.SnowCount];
        Vector4[] waterPositions = new Vector4[data.WaterCount];

        for (int i = 0; i < WorldWidth; i++)
        {
            for (int j = 0; j < WorldLength; j++)
            {
                for (int k = 0; k < WorldHeight; k++)
                {
                    if (_world[i,j,k] == BlockType.GRASS)
                    {
                        grassPositions[grassIndex] = new Vector4(i, k, j, 1);
                        grassIndex++;
                    }
                    if (_world[i, j, k] == BlockType.DIRT)
                    {
                        dirtPositions[dirtIndex] = new Vector4(i, k, j, 1);
                        dirtIndex++;
                    }
                    if (_world[i, j, k] == BlockType.SAND)
                    {
                        sandPositions[sandIndex] = new Vector4(i, k, j, 1);
                        sandIndex++;
                    }
                    if (_world[i, j, k] == BlockType.STONE)
                    {
                        stonePositions[stoneIndex] = new Vector4(i, k, j, 1);
                        stoneIndex++;
                    }
                    if (_world[i, j, k] == BlockType.SNOW)
                    {
                        snowPositions[snowIndex] = new Vector4(i, k, j, 1);
                        snowIndex++;
                    }
                    if (_world[i, j, k] == BlockType.WATER)
                    {
                        waterPositions[waterIndex] = new Vector4(i, k, j, 1);
                        waterIndex++;
                    }
                }
            }
        }

        grassBuffer.SetData(grassPositions);
        dirtBuffer.SetData(dirtPositions);
        sandBuffer.SetData(sandPositions);
        waterBuffer.SetData(waterPositions);
        snowBuffer.SetData(snowPositions);
        stoneBuffer.SetData(stonePositions);

        GrassMaterial.SetBuffer("positionBuffer", grassBuffer);
        DirtMaterial.SetBuffer("positionBuffer", dirtBuffer);
        SandMaterial.SetBuffer("positionBuffer", sandBuffer);
        StoneMaterial.SetBuffer("positionBuffer", stoneBuffer);
        WaterMaterial.SetBuffer("positionBuffer", waterBuffer);
        SnowMaterial.SetBuffer("positionBuffer", snowBuffer);

        // Grass
        if (GrassMesh != null)
        {
            args1[0] = (uint)GrassMesh.GetIndexCount(subMeshIndex);
            args1[1] = (uint)(data.GrassCount);
            args1[2] = (uint)GrassMesh.GetIndexStart(subMeshIndex);
            args1[3] = (uint)GrassMesh.GetBaseVertex(subMeshIndex);
        }
        else
        {
            args1[0] = args1[1] = args1[2] = args1[3] = 0;
        }
        grassArgs.SetData(args1);

        // Dirt
        if (DirtMesh != null)
        {
            args2[0] = (uint)DirtMesh.GetIndexCount(subMeshIndex);
            args2[1] = (uint)(data.DirtCount);
            args2[2] = (uint)DirtMesh.GetIndexStart(subMeshIndex);
            args2[3] = (uint)DirtMesh.GetBaseVertex(subMeshIndex);
        }
        else
        {
            args2[0] = args2[1] = args2[2] = args2[3] = 0;
        }
        dirtArgs.SetData(args2);

        // Sand
        if (SandMesh != null)
        {
            args3[0] = (uint)SandMesh.GetIndexCount(subMeshIndex);
            args3[1] = (uint)(data.SandCount);
            args3[2] = (uint)SandMesh.GetIndexStart(subMeshIndex);
            args3[3] = (uint)SandMesh.GetBaseVertex(subMeshIndex);
        }
        else
        {
            args3[0] = args3[1] = args3[2] = args3[3] = 0;
        }
        sandArgs.SetData(args3);

        // Stone
        if (StoneMesh != null)
        {
            args4[0] = (uint)StoneMesh.GetIndexCount(subMeshIndex);
            args4[1] = (uint)(data.StoneCount);
            args4[2] = (uint)StoneMesh.GetIndexStart(subMeshIndex);
            args4[3] = (uint)StoneMesh.GetBaseVertex(subMeshIndex);
        }
        else
        {
            args4[0] = args4[1] = args4[2] = args4[3] = 0;
        }
        stoneArgs.SetData(args4);

        // Snow
        if (SnowMesh != null)
        {
            args5[0] = (uint)SnowMesh.GetIndexCount(subMeshIndex);
            args5[1] = (uint)(data.SnowCount);
            args5[2] = (uint)SnowMesh.GetIndexStart(subMeshIndex);
            args5[3] = (uint)SnowMesh.GetBaseVertex(subMeshIndex);
        }
        else
        {
            args5[0] = args5[1] = args5[2] = args5[3] = 0;
        }snowArgs.SetData(args5);

        // Water
        if (WaterMesh != null)
        {
            args6[0] = (uint)WaterMesh.GetIndexCount(subMeshIndex);
            args6[1] = (uint)(data.WaterCount);
            args6[2] = (uint)WaterMesh.GetIndexStart(subMeshIndex);
            args6[3] = (uint)WaterMesh.GetBaseVertex(subMeshIndex);
        }
        else
        {
            args6[0] = args6[1] = args6[2] = args6[3] = 0;
        }
        waterArgs.SetData(args6);

        GameObject.FindGameObjectWithTag("Blocks").GetComponent<TMP_Text>().text = "Blocks: " + _totalBlocks;
        GameObject.FindGameObjectWithTag("Rendered").GetComponent<TMP_Text>().text = "Rendered: " + _renderedBlocks;
    }

    void OnDisable()
    {
        if (grassBuffer != null)
            grassBuffer.Release();
        grassBuffer = null;

        if (dirtBuffer != null)
            dirtBuffer.Release();
        dirtBuffer = null;

        if (sandBuffer != null)
            sandBuffer.Release();
        sandBuffer = null;

        if (stoneBuffer != null)
            stoneBuffer.Release();
        stoneBuffer = null;

        if (snowBuffer != null)
            snowBuffer.Release();
        snowBuffer = null;

        if (waterBuffer != null)
            waterBuffer.Release();
        waterBuffer = null;

        if (grassArgs != null)
            grassArgs.Release();
        grassArgs = null;

        if (dirtArgs != null)
            dirtArgs.Release();
        dirtArgs = null;

        if (sandArgs != null)
            sandArgs.Release();
        sandArgs = null;

        if (stoneArgs != null)
            stoneArgs.Release();
        grassArgs = null;

        if (snowArgs != null)
            snowArgs.Release();
        snowArgs = null;

        if (waterArgs != null)
            waterArgs.Release();
        waterArgs = null;
    }

    private void OcclusionCulling()
    {
        BlockType[,,] _newWorld = new BlockType[WorldWidth, WorldLength, WorldHeight];

        for (int i = 0; i < WorldWidth; i++)
        {
            for (int j = 0; j < WorldLength; j++)
            {
                for (int k = 0; k < WorldHeight; k++)
                {
                    if (!Visible(i,j,k))
                    {
                        if (_world[i,j,k] == BlockType.GRASS)
                        {
                            data.GrassCount--;
                        }
                        if (_world[i, j, k] == BlockType.DIRT)
                        {
                            data.DirtCount--;
                        }
                        if (_world[i, j, k] == BlockType.SAND)
                        {
                            data.SandCount--;
                        }
                        if (_world[i, j, k] == BlockType.STONE)
                        {
                            data.StoneCount--;
                        }
                        if (_world[i, j, k] == BlockType.SNOW)
                        {
                            data.SnowCount--;
                        }
                        if (_world[i, j, k] == BlockType.WATER)
                        {
                            data.WaterCount--;
                        }
                        _newWorld[i,j,k] = BlockType.AIR;
                    }
                    else
                    {
                        _newWorld[i, j, k] = _world[i, j, k];
                    }
                }
            }
        }
        _world= _newWorld;
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
