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
    [SerializeField] int WorldLength;
    [SerializeField] int WorldWidth;
    [SerializeField] int WorldHeight;
    [SerializeField] float WorldScale;

    [SerializeField] GameObject DirtTile;
    [SerializeField] GameObject StoneTile;
    [SerializeField] GameObject SnowTile;
    [SerializeField] GameObject GrassTile;
    [SerializeField] GameObject WaterTile;
    [SerializeField] GameObject SandTile;

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
                    }
                    if (_world[i,j,k] == BlockType.STONE)
                    {
                        _totalBlocks++;
                        if (!Visible(i, j, k)) continue;

                        GameObject tile = Instantiate(StoneTile, new Vector3(i, k, j), Quaternion.identity);
                        _tiles.Add(tile);
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
