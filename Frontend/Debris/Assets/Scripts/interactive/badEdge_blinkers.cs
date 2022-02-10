using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;
using UnityEngine;
using UnityEngine.UI;

public class badEdge_blinkers : MonoBehaviour {

    public Toggle blink_profit, blink_intersect, blink_time;
    private List<string>[] bad_edges;
    private bool on = true;
    private string[] badEdge_path;

    private void Awake()
    {
        Manager.Instance.suggest = new int[] { 0,0,0};

        //store path cases
        badEdge_path = new string[2];
        //there are three badedge cases: time/profit and intersection
        badEdge_path[0] = Application.streamingAssetsPath + "/Database/Input/badEdges_from_Matlab.csv";
        badEdge_path[1] = Application.streamingAssetsPath + "/Database/Input/badEdges_from_Matlab2.csv";

        reset_badEdge();
    }

    //delete badEdge file so that matlab can rewrite it
    private void reset_badEdge()
    {
        foreach(string bad_path in badEdge_path)
        {
            if (File.Exists(bad_path))
            {
                File.CreateText(bad_path).Dispose();
                File.Delete(bad_path);
            }
        }

        //store badedge info for diff cases
        bad_edges = new List<string>[2];
        bad_edges[0] = new List<string>();
        bad_edges[1] = new List<string>();
    }

    //read the badEdge file after matlab done writing it
    public void read_badEdges()
    {
        List<string[]> badEdges = new List<string[]>();
        int i = 0; //flag to check badEdges list for all cases;

        foreach (string bad_path in badEdge_path)
        {
            if (!File.Exists(bad_path))
            {
                Debug.Log("something went wrong with matlab there is no badedge file available");
                //GameObject.FindGameObjectWithTag("GameController").GetComponent<graph_view>().error_msg_open();
                continue;
            }
            else
            {
                try
                {
                    badEdges.Add(File.ReadAllLines(bad_path));

                    foreach (string badEdge in badEdges[i])
                    {
                        string[] bE_info = new string[2];
                        bE_info = badEdge.Split(',');

                        string badEdge_info = bE_info[0] + "_" + bE_info[1];

                        if (bad_edges[i] == null)
                        {
                            bad_edges[i].Add(badEdge_info);
                        }
                        else if(!bad_edges[i].Contains(badEdge_info))
                        {
                            bad_edges[i].Add(badEdge_info);
                        }
                    }

                    i++; //move on to next case;
                    Debug.Log("Done reading badEdge file");
                }
                catch (Exception e)
                {
                    Debug.Log("the file couldnt be read - " + e.Message);
                    //GameObject.FindGameObjectWithTag("GameController").GetComponent<graph_view>().error_msg_open();
                    continue;
                }
            }
        }
    }

    //get em blinking yo!! Are coroutines the best way to do this? I need to read up on these. 
    public void makeEm_blink(GameObject toggle)
    {
        //read_badEdges();
        on = toggle.GetComponent<Toggle>().isOn;

        //fix the toggle swap issue, now one has to turn toggle on and off individual before moving on
        switch (toggle.name)
        {
            case "Intersect_toggle":
                if (on)
                {
                    blink_profit.interactable = false;
                    blink_time.interactable = false;
                }
                else
                {
                    blink_profit.interactable = true;
                    blink_time.interactable = true;
                }
                break;
            case "Profit_toggle":
                if (on)
                {
                    blink_intersect.interactable = false;
                    blink_time.interactable = false;
                }
                else
                {
                    blink_intersect.interactable = true;
                    blink_time.interactable = true;
                }
                break;
            case "Time_toggle":
                if (on)
                {
                    blink_profit.interactable = false;
                    blink_intersect.interactable = false;
                }
                else
                {
                    blink_profit.interactable = true;
                    blink_intersect.interactable = true;
                }
                break;
        }

        if (bad_edges != null)
        {
            int this_case = 0;

            if (toggle.name.StartsWith("Profit") || toggle.name.StartsWith("Time"))
                this_case = 0;
            else
                this_case = 1;

            Manager.Instance.suggest[this_case] += 1;
            StartCoroutine(blinkers(this_case));
        }
    }

    public IEnumerator blinkers(int tog_no)
    {
        GameObject[] redLine = GameObject.FindGameObjectsWithTag("red");
        GameObject[] greenLine = GameObject.FindGameObjectsWithTag("green");
        GameObject[] blueLine = GameObject.FindGameObjectsWithTag("blue");
        GameObject[] white = GameObject.FindGameObjectsWithTag("white");
        GameObject[] red_blue = GameObject.FindGameObjectsWithTag("red+blue");
        GameObject[] red_green = GameObject.FindGameObjectsWithTag("red+green");
        GameObject[] green_blue = GameObject.FindGameObjectsWithTag("green+blue");
        GameObject[] all_color = GameObject.FindGameObjectsWithTag("AllColor");

        //Queue<string> badEdges = new Queue<string>();
        while (on)
        {
            foreach (string bad_edge in bad_edges[tog_no])
            {
                update_bad(redLine, bad_edge, true);
                update_bad(greenLine, bad_edge, true);
                update_bad(blueLine, bad_edge, true);
                update_bad(white,bad_edge,true);
                update_bad(red_blue,bad_edge,true);
                update_bad(red_green, bad_edge, true);
                update_bad(green_blue, bad_edge, true);
                update_bad(all_color,bad_edge,true);
            }

            yield return new WaitForSeconds(0.5f);

            foreach (string bad_edge in bad_edges[tog_no])
            {
                update_bad(redLine, bad_edge, false);
                update_bad(greenLine, bad_edge, false);
                update_bad(blueLine, bad_edge, false);
                update_bad(white, bad_edge, false);
                update_bad(red_blue, bad_edge, false);
                update_bad(red_green, bad_edge, false);
                update_bad(green_blue, bad_edge, false);
                update_bad(all_color, bad_edge, false);
            }

            yield return new WaitForSeconds(0.5f);
        }
    }

    void update_bad(GameObject[] lines, string bad_edge, bool on)
    {
        Vector3 wobble = new Vector3(.1f, .1f, 0);

        foreach (GameObject line in lines)
        {
            //Color lineColor = line.GetComponent<SpriteRenderer>().color;

            if (line.name.EndsWith("_" + bad_edge))
            {
                if(on)
                {
                    line.GetComponent<SpriteRenderer>().color = new Color(1,1,1,0.2f);
                    //line.GetComponent<Transform>().localScale += wobble;
                }
                else
                {
                    line.GetComponent<SpriteRenderer>().color = new Color(1, 1, 1, 1) ;
                    //line.GetComponent<Transform>().localScale -= wobble;
                }
            }
        }
    }
}