using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static Blocks;
using UnityEngine.UIElements;

public class Perlin_Noise_Generation
{
    private float w, l, h, scale;

    public Perlin_Noise_Generation(int worldWidth, int worldLength, int worldHeight, float worldScale)
    {
        w = worldWidth;
        l = worldLength;
        h = worldHeight;
        scale = worldScale;
    }

    public BlockType[,,] GenerateWorld(Vector2 offset)
    {
        BlockType[,,] world = new BlockType[(int)w, (int)l, (int)h];

        for (int i = 0; i < w; i++)
        {
            for (int j = 0; j < l; j++)
            {
                for (int k = 0; k < h; k++)
                {
                    world[i, j, k] = BlockType.AIR;
                }
            }
        }

        for (int i = 0; i < w; i++)
        {
            for (int j = 0; j < l; j++)
            {
                float sample = Mathf.PerlinNoise(offset.x + i / w * scale, offset.y + j / l * scale);
                int maxHeight = (int)(sample * (float)h);

                // Fill Surface
                if (maxHeight < 0.3f * h)
                {
                    world[i, j, (int)(0.3f * h)] = BlockType.WATER;
                    for (int k = (int)(0.3f * h) - 1; k >= maxHeight; k--)
                    {
                        //Debug.Log("Height:" + k + "  Array:" + world.GetLength(2));
                        world[i, j, k] = BlockType.WATER;
                    }
                }
                else if (maxHeight < 0.4f * h)
                {
                    world[i, j, maxHeight] = BlockType.SAND;
                }
                else if (maxHeight < 0.7f * h)
                {
                    world[i, j, maxHeight] = BlockType.GRASS;
                }
                else if (maxHeight < 0.84f * h)
                {
                    world[i, j, maxHeight] = BlockType.STONE;
                }
                else if (maxHeight >= 0.84f * h)
                {
                    world[i, j, maxHeight] = BlockType.SNOW;
                }

                // Fill Subterrain
                for (int k = maxHeight - 1; k >= 0; k--)
                {
                    world[i, j, k] = BlockType.DIRT;
                }
            }
        }

        return world;
    }
}
