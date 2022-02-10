using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System;
using System.IO;
using System.Text;

public class contInfo_Matlab : classSocket
{
    string csvPath;
    string[] readFile;
    int count_edges = 0, run_count = 0;
    bool error_flag = false;

    private void Awake()
    {
        count_edges = 0;

        csvPath = Application.streamingAssetsPath + "/Database/Output/edgelist_forMatlab.csv";

        write_CSV(csvPath);

        if (Manager.Instance.sessionId == "" || Manager.Instance.playerId == "" || Manager.Instance.sessionId == "def" || Manager.Instance.playerId == "def")
        {
            Manager.Instance.playerId = "def";
            Manager.Instance.sessionId = "def";

            string log_directory = Application.streamingAssetsPath + "/Database/Output/" + Manager.Instance.playerId + "_" + Manager.Instance.sessionId;

            if (!Directory.Exists(log_directory))
                Directory.CreateDirectory(log_directory);

            System.IO.DirectoryInfo di = new DirectoryInfo(log_directory);

            foreach(var fold in di.GetDirectories())
            {
                foreach (FileInfo file in fold.GetFiles())
                {
                    file.Delete();
                }
                fold.Delete();
            }
            foreach (FileInfo file in di.GetFiles())
            {
                file.Delete();
            }
        }

        //mark color start as false unless said otherwise via generate cnc method
        Manager.Instance.color_start = false;
    }

    private void Start()
    {
        string debris_path = Application.streamingAssetsPath + "/Database/Output/debris.csv";
        StringBuilder deb = new StringBuilder();
        foreach (float debris in Manager.Instance.debrisList)
        {
            string objline = string.Format("{0}", debris);
            deb.AppendLine(objline);
        }
        File.WriteAllText(debris_path, deb.ToString());
    }

    //when we start off with a contractor list on the map run this function.
    public bool run_generatecnc()
    {
        GameObject[] themWhiteEdges = GameObject.FindGameObjectsWithTag("white");
        if (themWhiteEdges.Length <= 1)
        {
           // Manager.Instance.debris_check = 0;
            Manager.Instance.color_start = true;
            read_contractor_info(0, 0, 0, true);

            return true;
        }
        return false;
    }

    //write out the csv for matlab to read
    void write_CSV(string path)
    {
        //if files doesn't exist make it
        if(!File.Exists(path))
        {
            File.WriteAllText(path, "-,-,-\n");
        }
        else
        {
            File.WriteAllText(path, string.Empty);
        }
    }

    //read all the contractor info and then write that info into csv
    public void read_contractor_info(int profit, int time, int intersect, bool rerun = false)
    {
        GameObject[] themWhiteEdges = GameObject.FindGameObjectsWithTag("white");
        //if ((themWhiteEdges.Length == 1 && themWhiteEdges[0].name == "white") || Manager.Instance.scans > 0)
       // {
        if(!rerun) // when rerun that is a scan zero
            Manager.Instance.scans += 1;
        Manager.Instance.edge_changes = 0;

        int count_edges = write_map_csv(csvPath, false, profit, time, intersect);

        Debug.Log("writting complete!! total edges - " + count_edges);

        //setup the client for the matlab server to read
        if(run_count != Manager.Instance.run || rerun || (Manager.Instance.scans == 1 && !Manager.Instance.color_start))
        {
            run_count = Manager.Instance.run;
            setupSocket(true);
        }
        else
            setupSocket(false);

        call_reading(profit, time, intersect);
       // }
    }

    public void write_log(string path, int profit_obj, int time_obj, int intersect_obj)
    {
        write_map_csv(path, true, profit_obj, time_obj, intersect_obj);
    }

    //write into csv file
    private int write_map_csv(string path, bool score, int profit_obj, int time_obj, int intersect_obj)
    {
        File.WriteAllText(path, string.Empty);

        GameObject[] themRedEdges = GameObject.FindGameObjectsWithTag("red");
        GameObject[] themGreenEdges = GameObject.FindGameObjectsWithTag("green");
        GameObject[] themBlueEdges = GameObject.FindGameObjectsWithTag("blue");
        GameObject[] themWhiteEdges = GameObject.FindGameObjectsWithTag("white");
        GameObject[] red_blue = GameObject.FindGameObjectsWithTag("red+blue");
        GameObject[] red_green = GameObject.FindGameObjectsWithTag("red+green");
        GameObject[] green_blue = GameObject.FindGameObjectsWithTag("green+blue");
        GameObject[] all_color = GameObject.FindGameObjectsWithTag("AllColor");
            List<GameObject[]> lines_ = new List<GameObject[]>
            {
                themRedEdges, themGreenEdges, themBlueEdges, themWhiteEdges, red_blue, red_green, green_blue, all_color
            };

        StringBuilder csv = new StringBuilder();
        count_edges = 0;
        string csv_input;

        //write the scores in for log
        //if(score)
        //{
        //    csv_input = write_scores();
        //    if (csv_input.EndsWith("\r\n"))
        //    {
        //        csv_input = csv_input.Substring(0, csv_input.Length - 2);
        //        csv.AppendLine(csv_input);
        //    }
        //
        //    string scanFile = Application.streamingAssetsPath + "/Database/Input/brushedEdges_Matlab.csv";
        //
        //    if (!File.Exists(scanFile))
        //    {
        //        score = false;
        //    }
        //    else
        //    {
        //        try
        //        {
        //            //read brushed file
        //            readFile = File.ReadAllLines(scanFile);
        //            Debug.Log("read brushed file");
        //            error_flag = false;
        //        }
        //        catch (Exception e)
        //        {
        //            error_flag = true;
        //            Debug.Log("the file couldnt be read - " + e.Message);
        //        }
        //        
        //    }
        //}

        //putting up obj category info
        string objline = string.Format("{0},{1},{2}", profit_obj, time_obj, intersect_obj);
        csv.AppendLine(objline);

        //write edges here
        foreach (GameObject[] lines in lines_)
        {
            csv_input = write_edges(path, lines, score);
            if (csv_input.EndsWith("\r\n"))
            {
                csv_input = csv_input.Substring(0, csv_input.Length - 2);
                csv.AppendLine(csv_input);
            }
        }

        //write down the edge list for matlab
        File.WriteAllText(path, csv.ToString());
        return count_edges;
    }

    //private string write_scores()
    //{
    //    StringBuilder csv = new StringBuilder();
    //    string[] nodeInfo = new string[4];
    //
    //    csv.AppendLine("first time, three scores, then objinputs+edgelist");
    //
    //    float timeLog = Manager.Instance.time_played;
    //    csv.AppendLine(timeLog.ToString());
    //
    //    string suggest = string.Format("{0},{1},{2}", Manager.Instance.suggest[0].ToString(), Manager.Instance.suggest[1].ToString(), Manager.Instance.suggest[2].ToString());
    //    csv.AppendLine(suggest);
    //
    //    for (int i = 0; i < 3; i++)
    //    {
    //        string cncline = string.Format("{0},{1},{2}", Manager.Instance.cncProfit[i], Manager.Instance.cncTime[i], (i + 1));
    //        csv.AppendLine(cncline);
    //    }
    //
    //    string newline = string.Format("{0},{1},Fullscore", Manager.Instance.maxProfit, Manager.Instance.minTime);
    //    csv.AppendLine(newline);
    //
    //    return csv.ToString();
    //}

    private string write_edges(string path, GameObject[] edges, bool score)
    {
        string from = "-";
        string to = "-";
        string nc = "";
        StringBuilder csv = new StringBuilder();
        string[] nodeInfo = new string[4];

        if (edges[0].name == "white")
            nc = "";
        else
        {
            if (edges[0].name.Contains("red"))
                nc += "1";
            if (edges[0].name.Contains("green"))
                nc += "2";
            if (edges[0].name.Contains("blue"))
                nc += "3";
        }

        for (int i = 0; i < edges.Length; i++)
        {
            nodeInfo = edges[i].name.Split('_');
            if (nodeInfo.Length > 2)
            {
                from = nodeInfo[2];
                to = nodeInfo[3];
        
                if (from != "-" || to != "-")
                {
                    string newline;

                    //if (score && !error_flag)
                    //{
                    //    string[] scoreInfo = new string[3];
                    //    // scoreInfo = readFile[count_edges].Split(',');
                    //    // newline = string.Format("{0},{1},{2},{3},{4},{5},{6}", from, to, nc, "-", scoreInfo[0], scoreInfo[1], scoreInfo[2]);
                    //    newline = string.Format("{0},{1},{2}", from, to, nc);
                    //}
                    //else
                    {
                        newline = string.Format("{0},{1},{2}", from, to, nc);
                    }
                    csv.AppendLine(newline);
                    count_edges += 1;
                }
            }
        }
        
        return csv.ToString();
    }

    //read score sent from matlab
    private void call_reading(int profit_obj, int time_obj, int intersect_obj, bool rerun = false)
    {
        GameObject gameManager = GameObject.Find("GameManager") ;
        read_Score read = (read_Score)gameManager.GetComponent(typeof(read_Score));

        //start reading
        read.reading(profit_obj, time_obj, intersect_obj, rerun);   
    }
}