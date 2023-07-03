using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using static Blocks;

public class GPU_Instancer : MonoBehaviour
{
    [SerializeField] public int WorldWidth;
    [SerializeField] public int WorldLength;
    [SerializeField] public int WorldHeight;
    [SerializeField] public float WorldScale;
    [SerializeField] public bool Foliage;

    [SerializeField] float treeScale = 2;
    [SerializeField] Vector3 treeOffset = new Vector3(0, -0.5f, 0);

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

    [SerializeField] public Mesh TreeMesh;
    [SerializeField] public Material TreeMaterial;
    [SerializeField] public Mesh BushMesh;
    [SerializeField] public Material BushMaterial;
    [SerializeField] public Mesh Grass1Mesh;
    [SerializeField] public Material Grass1Material;
    [SerializeField] public Mesh Grass2Mesh;
    [SerializeField] public Material Grass2Material;
    [SerializeField] public Mesh RockMesh;
    [SerializeField] public Material RockMaterial;

    private List<List<Matrix4x4>> GrassBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> DirtBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> WaterBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> SandBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> StoneBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> SnowBatches = new List<List<Matrix4x4>>();

    private List<List<Matrix4x4>> TreeBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> BushBatches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> Grass1Batches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> Grass2Batches = new List<List<Matrix4x4>>();
    private List<List<Matrix4x4>> RockBatches = new List<List<Matrix4x4>>();

    private BlockType[,,] _world;

    private int _totalBlocks;
    private int _renderedBlocks;

    private Perlin_Noise_Generation _perlin_generator;

    private void Update()
    {
        RenderBatches(GrassBatches, GrassMesh, GrassMaterial);
        RenderBatches(DirtBatches, DirtMesh, DirtMaterial);
        RenderBatches(WaterBatches, WaterMesh, WaterMaterial);
        RenderBatches(SandBatches, SandMesh, SandMaterial);
        RenderBatches(StoneBatches, StoneMesh, StoneMaterial);
        RenderBatches(SnowBatches, SnowMesh, SnowMaterial);

        if (Foliage)
        {
            RenderBatches(TreeBatches, TreeMesh, TreeMaterial);
            RenderBatches(BushBatches, BushMesh, BushMaterial);
            //RenderBatches(Grass1Batches, Grass1Mesh, Grass1Material);
            //RenderBatches(Grass2Batches, Grass2Mesh, Grass2Material);
            RenderBatches(RockBatches, RockMesh, RockMaterial);
        }
    }

    public void Regenerate()
    {
        _totalBlocks = 0;
        _renderedBlocks = 0;

        GrassBatches.Clear();
        DirtBatches.Clear();
        SandBatches.Clear();
        WaterBatches.Clear();
        SnowBatches.Clear();
        StoneBatches.Clear();

        TreeBatches.Clear();
        BushBatches.Clear();
        Grass1Batches.Clear();
        Grass2Batches.Clear();
        RockBatches.Clear();

        _perlin_generator = new Perlin_Noise_Generation(WorldWidth, WorldLength, WorldHeight, WorldScale);

        _world = _perlin_generator.GenerateWorld(new Vector2(Random.Range(0, 1000), Random.Range(0, 1000)));

        GenerateBatches();
    }

    private void Start()
    {
        _perlin_generator = new Perlin_Noise_Generation(WorldWidth, WorldLength, WorldHeight, WorldScale);

        _world = _perlin_generator.GenerateWorld(new Vector2(Random.Range(0, 1000), Random.Range(0, 1000)));

        GenerateBatches();

    }

    private void GenerateBatches()
    {
        int grassBlocks = 0;
        int dirtBlocks = 0;
        int waterBlocks = 0;
        int sandBlocks = 0;
        int stoneBlocks = 0;
        int snowBlocks = 0;

        int treeBlocks = 0;
        int bushBlocks = 0;
        int grass1Blocks = 0;
        int grass2Blocks = 0;
        int rockBlocks = 0;

        GrassBatches.Add(new List<Matrix4x4>());
        DirtBatches.Add(new List<Matrix4x4>());
        SandBatches.Add(new List<Matrix4x4>());
        WaterBatches.Add(new List<Matrix4x4>());
        StoneBatches.Add(new List<Matrix4x4>());
        SnowBatches.Add(new List<Matrix4x4>());

        if (Foliage)
        {
            TreeBatches.Add(new List<Matrix4x4>());
            BushBatches.Add(new List<Matrix4x4>());
            Grass1Batches.Add(new List<Matrix4x4>());
            Grass2Batches.Add(new List<Matrix4x4>());
            RockBatches.Add(new List<Matrix4x4>());
        }

        for (int i = 0; i < WorldWidth; i++)
        {
            for (int j = 0; j < WorldLength; j++)
            {
                for (int k = 0; k < WorldHeight; k++)
                {
                    if (_world[i, j, k] == BlockType.GRASS)
                    {
                        _totalBlocks++;

                        if (!Visible(i, j, k))
                            continue;

                        _renderedBlocks++;

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

                        if (!Foliage)
                            continue;

                        // Trees
                        if (Random.Range(0, 1f) > 0.8)
                        {
                            if (treeBlocks < 1000)
                            {
                                TreeBatches[TreeBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i + treeOffset.x, k + treeOffset.y, j + treeOffset.z), Quaternion.identity, Vector3.one * treeScale));
                                treeBlocks++;
                            }
                            else
                            {
                                TreeBatches.Add(new List<Matrix4x4>());
                                TreeBatches[TreeBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i + treeOffset.x, k + treeOffset.y, j + treeOffset.z), Quaternion.identity, Vector3.one * treeScale));
                                treeBlocks = 1;
                            }
                            continue;
                        }

                        // Bushes
                        if (Random.Range(0, 1f) > 0.9)
                        {
                            if (bushBlocks < 1000)
                            {
                                BushBatches[BushBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                                bushBlocks++;
                            }
                            else
                            {
                                BushBatches.Add(new List<Matrix4x4>());
                                BushBatches[BushBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                                bushBlocks = 1;
                            }
                            continue;
                        }

                        //// Grass 1
                        //if (Random.Range(0, 1f) > 0.9)
                        //{
                        //    if (grass1Blocks < 1000)
                        //    {
                        //        Grass1Batches[Grass1Batches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                        //        grass1Blocks++;
                        //    }
                        //    else
                        //    {
                        //        Grass1Batches.Add(new List<Matrix4x4>());
                        //        Grass1Batches[Grass1Batches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                        //        grass1Blocks = 1;
                        //    }
                        //}

                        //// Grass 2
                        //if (Random.Range(0, 1f) > 0.9)
                        //{
                        //    if (grass2Blocks < 1000)
                        //    {
                        //        Grass2Batches[Grass2Batches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                        //        grass2Blocks++;
                        //    }
                        //    else
                        //    {
                        //        Grass2Batches.Add(new List<Matrix4x4>());
                        //        Grass2Batches[Grass2Batches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                        //        grass2Blocks = 1;
                        //    }
                        //}
                    }
                    if (_world[i, j, k] == BlockType.DIRT)
                    {
                        _totalBlocks++;

                        if (!Visible(i, j, k))
                            continue;

                        _renderedBlocks++;


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
                        _totalBlocks++;

                        if (!Visible(i, j, k))
                            continue;

                        _renderedBlocks++;


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
                        _totalBlocks++;

                        if (!Visible(i, j, k))
                            continue;

                        _renderedBlocks++;


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
                        _totalBlocks++;

                        if (!Visible(i, j, k))
                            continue;

                        _renderedBlocks++;


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

                        if (!Foliage)
                            continue;

                        // Rocks
                        if (Random.Range(0, 1f) > 0.8 && k > 0)
                        {
                            if (rockBlocks < 1000)
                            {
                                RockBatches[RockBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                                rockBlocks++;
                            }
                            else
                            {
                                RockBatches.Add(new List<Matrix4x4>());
                                RockBatches[RockBatches.Count - 1].Add(Matrix4x4.TRS(new Vector3(i, k, j), Quaternion.identity, Vector3.one));
                                rockBlocks = 1;
                            }
                        }
                    }
                    if (_world[i, j, k] == BlockType.SNOW)
                    {
                        _totalBlocks++;

                        if (!Visible(i, j, k))
                            continue;

                        _renderedBlocks++;


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

        GameObject.FindGameObjectWithTag("Blocks").GetComponent<TMP_Text>().text = "Blocks: " + _totalBlocks;
        GameObject.FindGameObjectWithTag("Rendered").GetComponent<TMP_Text>().text = "Rendered: " + _renderedBlocks;
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

    private void RenderBatches(List<List<Matrix4x4>> Batch, Mesh mesh, Material[] materials)
    {
        foreach (var batch in Batch)
        {
            for (int i = 0; i < mesh.subMeshCount; i++)
            {
                Graphics.DrawMeshInstanced(mesh, i, materials[i], batch);
            }
        }
    }

    private bool Visible(int i, int j, int k)
    {
        if (i == 0 || i == WorldWidth - 1) return true;
        if (j == 0 || j == WorldLength - 1) return true;
        if (k == 0 || k == WorldHeight - 1) return true;

        //if (_world[i, j, k] == BlockType.WATER) return true;

        if (_world[i, j, k + 1] == BlockType.AIR || _world[i, j, k - 1] == BlockType.AIR) return true;
        if (_world[i, j + 1, k] == BlockType.AIR || _world[i, j - 1, k] == BlockType.AIR) return true;
        if (_world[i + 1, j, k] == BlockType.AIR || _world[i - 1, j, k] == BlockType.AIR) return true;

        if (_world[i, j, k] != BlockType.WATER) { 
            if (_world[i, j, k + 1] == BlockType.WATER || _world[i, j, k - 1] == BlockType.WATER) return true;
            if (_world[i, j + 1, k] == BlockType.WATER || _world[i, j - 1, k] == BlockType.WATER) return true;
            if (_world[i + 1, j, k] == BlockType.WATER || _world[i - 1, j, k] == BlockType.WATER) return true;
        }

        return false;
    }

}
