using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

public class Manager : Singleton<Manager>
{
    public int mySelection = 1;
    public float brushSize = 70;

    public List<float> debrisList;
    public List<float> TimesList;

    public string map_json;

    public int map_version = 0;
    public bool flag = false; //flag checking whether map coloring has been changed or not
    public int edge_changes = 0;

    public int on_ver = 0; //to check which version we are on right now.
    public int[] suggest = new int[3]; //suggest clicks per scan
    public int scans = 0; //number of scans done
    public bool color_start = false;
    public int run = 0;
    public float maxProfit, minTime, intersect; //the scores for the game
    public int debris_check = 0;

    public float time_played = 0;

    //the scores for individual contractors
    public float[] cncProfit = new float[3];
    public float[] cncTime = new float[3];

    //player id and session id 
    public string playerId = "def", sessionId = "def";

    //play time
    public float playTime;

    public List<Dictionary<string, string>> map_info = new List<Dictionary<string, string>>();

    public void reset_game()
    {
        //do the run update on its own
        scans = 0;
        on_ver = scans;
        edge_changes = 0;
        map_version = 0;
        debris_check = 0;
    }

    //save contractor information for the map 
    public void save_map(int map_ver, GameObject edge)
    {
        string[] nodeInfo = new string[4];
        bool remove = false;
        bool add = false;

        //we only want 5 versions of map save
        if (map_ver > 4)
        {
            //Array.Copy(map_info, 1, map_info, 0, map_info.Count - 1);
            for(int i = 1; i <= 4; i ++)
            {
                map_info[i - 1] = map_info[i];
            }
                
            map_info.RemoveAt(4);
            map_version -= 1;
        }

        nodeInfo = edge.name.Split('_');
        try
        {
            if (nodeInfo.Length > 2)
            {
                //intialise them dictionaries for current saves only
                if (map_info.Count <= map_ver+1)
                {
                    map_info.Add(new Dictionary<string, string>());
                        add = true;
                }

                if (map_info.Count > map_ver && Input.GetMouseButtonUp(0))
                {
                    //delete map info for older map versions existing over the current save version
                    for (int i = map_info.Count - 1; i > map_ver; i--)
                    {
                        map_info.RemoveAt(i);
                    }
                }

                //delete present keys when needed - correction for when you overwrite colors on the same turn
                if (map_info[map_ver].ContainsKey(edge.name))
                {
                    map_info[map_ver].Remove(edge.name);
                    remove = true;
                }

                //save current map version
                switch (edge.tag)
                {
                    case "red":
                        map_info[map_ver].Add(edge.name, "red");
                        break;
                    case "blue":
                        map_info[map_ver].Add(edge.name, "blue");
                        break;
                    case "green":
                        map_info[map_ver].Add(edge.name, "green");
                        break;
                    case "white":
                        map_info[map_ver].Add(edge.name, "white");
                        break;
                    case "red+green":
                        map_info[map_ver].Add(edge.name, "red+green");
                        break;
                    case "red+blue":
                        map_info[map_ver].Add(edge.name, "red+blue");
                        break;
                    case "green+blue":
                        map_info[map_ver].Add(edge.name, "green+blue");
                        break;
                    case "AllColor":
                        map_info[map_ver].Add(edge.name, "red+blue+green");
                        break;
                    default:
                        Debug.Log("something went wrong with edge mapping for undo/redo");
                        break;
                }
            }
        }
        catch (Exception e)
        {
            Debug.Log("wrong : " + edge.tag + " " + map_ver + "map_info :" + map_info.Count + " " + add + remove + " " + e.Message);
        }
    }
}