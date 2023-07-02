using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static Blocks;
using UnityEngine.UIElements;

public class Perlin_Noise_Generation
{
    private float w, l, h, scale;

    public struct WorldData
    {
        public BlockType[,,] _world;
        public int GrassCount, DirtCount, WaterCount, SandCount, StoneCount, SnowCount;
    }

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
                maxHeight = Mathf.Clamp(maxHeight, 0, (int)(h - 1));

                // Fill Surface
                if (maxHeight < 0.3f * h)
                {
                    world[i, j, (int)(0.3f * h)] = BlockType.WATER;
                    for (int k = (int)(0.3f * h) - 1; k >= 0; k--)
                    {
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

    public WorldData GenerateWorldData(Vector2 offset)
    {
        int dirt = 0;
        int water = 0;
        int grass = 0;
        int sand = 0;
        int stone = 0;
        int snow = 0;

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
                maxHeight = Mathf.Clamp(maxHeight, 0, (int)(h - 1));

                // Fill Surface
                if (maxHeight < 0.3f * h)
                {
                    world[i, j, (int)(0.3f * h)] = BlockType.WATER;
                    water++;
                    for (int k = (int)(0.3f * h) - 1; k >= 0; k--)
                    {
                        world[i, j, k] = BlockType.WATER;
                        water++;
                    }
                }
                else if (maxHeight < 0.4f * h)
                {
                    world[i, j, maxHeight] = BlockType.SAND;
                    sand++;
                }
                else if (maxHeight < 0.7f * h)
                {
                    world[i, j, maxHeight] = BlockType.GRASS;
                    grass++;
                }
                else if (maxHeight < 0.84f * h)
                {
                    world[i, j, maxHeight] = BlockType.STONE;
                    stone++;
                }
                else if (maxHeight >= 0.84f * h)
                {
                    world[i, j, maxHeight] = BlockType.SNOW;
                    snow++;
                }

                // Fill Subterrain
                for (int k = maxHeight - 1; k >= 0; k--)
                {
                    world[i, j, k] = BlockType.DIRT;
                    dirt++;
                }
            }
        }

        return new WorldData
        {
            _world = world,
            GrassCount = grass,
            DirtCount = dirt,
            SandCount = sand,
            SnowCount = snow,
            StoneCount = stone,
            WaterCount = water
        };
    }

}
