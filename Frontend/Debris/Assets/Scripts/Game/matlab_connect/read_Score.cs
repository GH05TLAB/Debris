using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;
using UnityEngine;

public class read_Score : MonoBehaviour
{
    StreamReader readScore;
    string scorePath;
    float start_time, timespent;
    bool reading_check;
    int profit_obj, time_obj, intersect_obj;

    private void Awake()
    {
        scorePath = Application.streamingAssetsPath + "/Database/Input/score_info_fromMatlab.txt";
        
        reset_score();

        //initialize log items : error check based on time; profit obj,time obj, intersect obj based on the buttons 
        //from scan control maybe I should move these manager? Fine for now.
        profit_obj = 0;
        time_obj = 0;
        intersect_obj = 0;
        reading_check = false;
        start_time = 0f;
        timespent = 0f;
    }

    private void Update()
    {
        if (reading_check)
        {
            timespent = Time.time - start_time;
            if(read_score())
            {
                Debug.Log("maxProfit : " + Manager.Instance.maxProfit);
                Debug.Log("minTime : " + Manager.Instance.minTime);

                for (int i = 0; i < 3; i++)
                {
                    Debug.Log("cnc profit_" + (i + 1) + " : " + Manager.Instance.cncProfit[i]);
                    Debug.Log("cnc time_" + (i + 1) + " : " + Manager.Instance.cncTime[i]);
                }
                Debug.Log("intersect overlap_" + Manager.Instance.intersect);

                GameObject.Find("MapScreen").GetComponent<badEdge_blinkers>().read_badEdges();
                GameObject.FindGameObjectWithTag("GameController").GetComponent<graph_view>().update_log(true, profit_obj, time_obj, intersect_obj);

                //not reading anymore
                reading_check = false;              
            }
            else if (timespent > 120)
            {
                Debug.Log("Matlab taking too long something wrong - " + timespent);

                GameObject.FindGameObjectWithTag("GameController").GetComponent<graph_view>().error_msg_open();
                GameObject.FindGameObjectWithTag("GameController").GetComponent<graph_view>().update_log(false, profit_obj, time_obj, intersect_obj);

                //not reading anymore
                reading_check = false;
            }
        }
    }

    //reset score file so that matlab can rewrite it
    private void reset_score()
    {
        if(File.Exists(scorePath))
        {
            File.Delete(scorePath);
        }
        
        //reset/init the file to waiting..
        //File.WriteAllText(scorePath,"waiting...");

        //reset/init variables
        Manager.Instance.minTime = 0; Manager.Instance.maxProfit = 0;
    }

    //read the score file written by matlab algo server thingy
    private bool read_score()
    {
        string[] initRead = new string[4];

        if(!File.Exists(scorePath))
        {
            return false;
        }
        else
        {
            try
            {
                initRead = File.ReadAllLines(scorePath);
            }
            catch (Exception e)
            {
                Debug.Log("the file couldnt be read - " + e.Message);
                //GameObject.FindGameObjectWithTag("GameController").GetComponent<graph_view>().error_msg_open();
                return false;
            }

            string[] scoreInfo = new string[3];

            foreach (string line in initRead)
            {
                scoreInfo = line.Split(',');

                if (scoreInfo.Length > 2)
                {
                    Manager.Instance.cncTime[int.Parse(scoreInfo[0])-1] = float.Parse(scoreInfo[1]);
                    Manager.Instance.cncProfit[int.Parse(scoreInfo[0])-1] = float.Parse(scoreInfo[2]);
                    Manager.Instance.intersect = float.Parse(scoreInfo[3]);
                }
                else
                {
                    Manager.Instance.minTime = float.Parse(scoreInfo[0]);
                    Manager.Instance.maxProfit = float.Parse(scoreInfo[1]);
                }
            }

            return true;
        }
    }
     
    //keep reading the score file while matlab is calculating and done writing the score file
    public void reading(int profit, int time, int intersect, bool rerun = false)
    {
        //reset score file so it be waiting for matlab new scores
        reset_score();
        Debug.Log("waiting on score...");

        start_time = Time.time;
        timespent = 0f;

        profit_obj = profit;
        time_obj = time;
        intersect_obj = intersect;

        //start reading
        reading_check = true;
        //continues in UPDATE;
    }
}
