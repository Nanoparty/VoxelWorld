using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Experimental.AI;
using UnityEngine.Rendering;
using UnityEngine.UIElements;
using static Blocks;

public class Standard_Instancer : MonoBehaviour
{
    [SerializeField] public int WorldLength;
    [SerializeField] public int WorldWidth;
    [SerializeField] public int WorldHeight;
    [SerializeField] public float WorldScale;
    [SerializeField] public bool Foliage;

    [SerializeField] GameObject DirtTile;
    [SerializeField] GameObject StoneTile;
    [SerializeField] GameObject SnowTile;
    [SerializeField] GameObject GrassTile;
    [SerializeField] GameObject WaterTile;
    [SerializeField] GameObject SandTile;

    [SerializeField] GameObject Tree;
    [SerializeField] GameObject Bush;
    [SerializeField] GameObject Grass1;
    [SerializeField] GameObject Grass2;
    [SerializeField] GameObject Rock;

    private BlockType[,,] _world;

    private List<GameObject> _tiles;
    private int _totalBlocks;

    private Perlin_Noise_Generation _perlin_generator;

    private void Start()
    {
        _tiles = new List<GameObject>();
        _perlin_generator = new Perlin_Noise_Generation(WorldWidth, WorldLength, WorldHeight, WorldScale);

        float random1 = Random.Range(0, 100);
        float random2 = Random.Range(0, 100);
        _world = _perlin_generator.GenerateWorld(new Vector2(random1, random2));

        RenderWorld();
    }

    private void Update()
    {
        if (Input.GetKey(KeyCode.Space))
        {
            
        }

    }

    public void Regenerate()
    {
        _totalBlocks = 0;

        foreach (GameObject o in _tiles)
        {
            Destroy(o);
        }
        _tiles.Clear();

        _perlin_generator = new Perlin_Noise_Generation(WorldWidth, WorldLength, WorldHeight, WorldScale);

        float random1 = Random.Range(0, 100);
        float random2 = Random.Range(0, 100);
        _world = _perlin_generator.GenerateWorld(new Vector2(random1, random2));

        RenderWorld();
    }

    private void RenderWorld()
    {
        for (int i = 0; i < WorldWidth; i++)
        {
            for (int j = 0; j < WorldLength; j++)
            {
                for (int k = 0; k < WorldHeight; k++)
                {
                    if (_world[i, j, k] == BlockType.GRASS)
                    {
                        _totalBlocks++;
                        if (!Visible(i, j, k)) continue;

                        GameObject tile = Instantiate(GrassTile, new Vector3(i, k, j), Quaternion.identity);
                        _tiles.Add(tile);

                        if (!Foliage)
                            continue;

                        if (Random.Range(0, 1f) > 0.8)
                        {
                            GameObject tree = Instantiate(Tree, new Vector3(i, k, j), Quaternion.identity);
                            _tiles.Add(tree);
                        }
                        else if (Random.Range(0, 1f) > 0.9)
                        {
                            GameObject bush = Instantiate(Bush, new Vector3(i, k, j), Quaternion.identity);
                            _tiles.Add(bush);
                        }
                        else if (Random.Range(0, 1f) > 0.9)
                        {
                            GameObject grass = Instantiate(Grass1, new Vector3(i, k, j), Quaternion.identity);
                            _tiles.Add(grass);
                        }
                        else if (Random.Range(0, 1f) > 0.9)
                        {
                            GameObject grass = Instantiate(Grass2, new Vector3(i, k, j), Quaternion.identity);
                            _tiles.Add(grass);
                        }
                    }
                    if (_world[i,j,k] == BlockType.STONE)
                    {
                        _totalBlocks++;
                        if (!Visible(i, j, k)) continue;

                        GameObject tile = Instantiate(StoneTile, new Vector3(i, k, j), Quaternion.identity);
                        _tiles.Add(tile);

                        if (!Foliage)
                            continue;

                        if (Random.Range(0, 1f) > 0.8 && k > 0)
                        {
                            GameObject rock = Instantiate(Rock, new Vector3(i, k, j), Quaternion.identity);
                            _tiles.Add(rock);
                        }
                    }
                    if (_world[i, j, k] == BlockType.SAND)
                    {
                        _totalBlocks++;
                        if (!Visible(i, j, k)) continue;

                        GameObject tile = Instantiate(SandTile, new Vector3(i, k, j), Quaternion.identity);
                        _tiles.Add(tile);
                    }
                    if (_world[i, j, k] == BlockType.SNOW)
                    {
                        _totalBlocks++;
                        if (!Visible(i, j, k)) continue;

                        GameObject tile = Instantiate(SnowTile, new Vector3(i, k, j), Quaternion.identity);
                        _tiles.Add(tile);
                    }
                    if (_world[i, j, k] == BlockType.WATER)
                    {
                        _totalBlocks++;
                        if (!Visible(i, j, k)) continue;

                        GameObject tile = Instantiate(WaterTile, new Vector3(i, k, j), Quaternion.identity);
                        _tiles.Add(tile);
                    }
                    if (_world[i, j, k] == BlockType.DIRT)
                    {
                        _totalBlocks++;
                        if (!Visible(i, j, k)) continue;

                        GameObject tile = Instantiate(DirtTile, new Vector3(i, k, j), Quaternion.identity);
                        _tiles.Add(tile);
                    }
                }
            }
        }

        GameObject.FindGameObjectWithTag("Blocks").GetComponent<TMP_Text>().text = "Blocks: " + _totalBlocks;
        GameObject.FindGameObjectWithTag("Rendered").GetComponent<TMP_Text>().text = "Rendered: " + _tiles.Count;
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

        if (_world[i, j, k] != BlockType.WATER)
        {
            if (_world[i, j, k + 1] == BlockType.WATER || _world[i, j, k - 1] == BlockType.WATER) return true;
            if (_world[i, j + 1, k] == BlockType.WATER || _world[i, j - 1, k] == BlockType.WATER) return true;
            if (_world[i + 1, j, k] == BlockType.WATER || _world[i - 1, j, k] == BlockType.WATER) return true;
        }

        return false;
    }
}
