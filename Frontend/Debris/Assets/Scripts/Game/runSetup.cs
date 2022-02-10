using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using LitJson;
using System;

//setting up run system front and back both
public class runSetup : MonoBehaviour
{
    private Camera gameCamera;
    private bool takeScreenShotonNextFrame;
    private string JSONstring;
    private static JsonData mapItem;
    private bool screenshotdone = false;
    private bool found_brush = false, brush_done = false;
    private bool print_header = false;
    private bool scan_ease_pic = false;

    private static runSetup instance;
    private static int x_, y_, w_, h_;

    private Dictionary<string, string> brush_map = new Dictionary<string, string>();

    private void Awake()
    {
        print_header = false;
        takeScreenShotonNextFrame = false;
        gameCamera = gameObject.GetComponent<Camera>();
        instance = this;
        string log_directory = Application.persistentDataPath + "/run_images";
        if (!Directory.Exists(log_directory))
        {
            Directory.CreateDirectory(log_directory);
        }
        else
        {
            System.IO.DirectoryInfo di = new DirectoryInfo(log_directory);
            foreach (FileInfo file in di.GetFiles())
            {
                file.Delete();
            }
        }
    }

    public static void reset_header()
    {
        instance.print_header = false;
    }

    private void OnPostRender()
    {
        if(takeScreenShotonNextFrame)
        {
            takeScreenShotonNextFrame = false;
            //-1 quick fix for file name management
            string run_image = Application.persistentDataPath + "/run_images" + "/run_" + (Manager.Instance.run - 1).ToString() + ".png";

            RenderTexture renderTex = gameCamera.targetTexture;

            Texture2D renderResult = new Texture2D(renderTex.width, renderTex.height, TextureFormat.RGBAFloat, false);
            Rect rect = new Rect(x_, y_, w_, h_);

            if (scan_ease_pic)
            {
                if (Manager.Instance.playerId == "" || Manager.Instance.sessionId == "")
                {
                    Manager.Instance.playerId = "def";
                    Manager.Instance.sessionId = "def";
                }

                string log_directory = Application.streamingAssetsPath + "/Database/Output/" + Manager.Instance.playerId + "_" + Manager.Instance.sessionId + "/scan_pics";
                if (!Directory.Exists(log_directory))
                {
                    Directory.CreateDirectory(log_directory);
                }

                run_image = log_directory + "/scan_" + Manager.Instance.scans + ".png";

                rect = new Rect(x_, y_, renderTex.width, renderTex.height);
            }

            renderResult.ReadPixels(rect, 0, 0);

            byte[] byteArr = renderResult.EncodeToPNG();
            System.IO.File.WriteAllBytes(run_image, byteArr);

            Debug.Log("image saved for run:" + Manager.Instance.run);
            Debug.Log(run_image);

            RenderTexture.ReleaseTemporary(renderTex);
            gameCamera.targetTexture = null;

            if (!scan_ease_pic) // dont done screenshot for scan help pic this is only for run_setup screenshot. I'm getting tired working on this now :(
                screenshot_done(true);
        }
    }

    //store map info for logging and stuffing
    private void Start()
    {
        JSONstring = File.ReadAllText(Manager.Instance.map_json);

        mapItem = JsonMapper.ToObject(JSONstring);
    }

    private void takeScreenShot(int width, int height)
    {
        gameCamera.targetTexture = RenderTexture.GetTemporary(width, height, 16);
        takeScreenShotonNextFrame = true;
    }

    public static void log_data(string path, int prft_obj, int time_obj, int inter_obj)
    {
        instance.logging(path, prft_obj, time_obj, inter_obj);
    }

    public static byte[] read_image(string path)
    {
        byte[] image = null;
        if (File.Exists(path))
        {
            image = File.ReadAllBytes(path);
            return image;
        }

        return image;
    }

    public static Dictionary<string, string> get_brush_map()
    {
        return instance.brush_map;
    }

    public static bool get_found_brush()
    {
        return instance.found_brush;
    }

    public static bool get_brush_done()
    {
        return instance.brush_done;
    }

    public static void set_brush_done(bool set)
    {
        instance.brush_done = set;
    }

    private void logging(string path, int prft_obj, int time_obj, int inter_obj)
    {
        StringBuilder csv = new StringBuilder();

        string line, debCheck, suggest, inputObj;
        int source, dest, number_of_edges = mapItem["EdgeData"].Count;

        //read the brushed_edges from matlab to log them here
        string scanFile = Application.streamingAssetsPath + "/Database/Input/brushedEdges_Matlab.txt";
        string[] readBrush = new string[number_of_edges + 1]; //+1 just to be extra safe but the brushfile cannot have more lines than number of edges
        bool brush_error = false;
        try
        {
            //read brushed file
            readBrush = File.ReadAllLines(scanFile);
            Debug.Log("read brushed file");
            brush_error = false;
        }
        catch (Exception e)
        {
            brush_error = true;
            Debug.Log("the file couldnt be read - " + e.Message);
        }

        //add the header
        if (!print_header)
        {
            print_header = true;
            line = "-,time_played,on_ver,MinProfit,MaxTime,red_profit,red_time,green_profit,green_time,blue_profit,blue_time,intersect,total_debCheck,total_suggest,input_obj";

            for (int i = 0; i < number_of_edges; i++)
            {
                source = (int)mapItem["EdgeData"][i]["From"];
                dest = (int)mapItem["EdgeData"][i]["To"];
                line += ',' + "E_" + source.ToString() + '_' + dest.ToString();
            }
                csv.AppendLine(line);
        }
        
        //add all info in for this scan
        line = "scans_" + Manager.Instance.scans.ToString() + ',' + Manager.Instance.time_played.ToString() + ',' + Manager.Instance.on_ver.ToString()+ ',' + Manager.Instance.maxProfit.ToString() + ',' + Manager.Instance.minTime.ToString();

        for (int i = 0; i < 3; i++)
        {
            line += ',' + Manager.Instance.cncProfit[i].ToString() + ',' + Manager.Instance.cncTime[i].ToString();
        }

        debCheck = Manager.Instance.debris_check.ToString();
        suggest = Manager.Instance.suggest[0].ToString() + '_' + Manager.Instance.suggest[1].ToString() + '_' + Manager.Instance.suggest[2].ToString();
        inputObj = prft_obj.ToString() + '_' + time_obj.ToString() + '_' + inter_obj.ToString();

        line += ',' + Manager.Instance.intersect.ToString() + ',' + debCheck + ',' + suggest + ',' + inputObj;

        brush_map.Clear();
        for (int i = 0; i < number_of_edges; i++)
        {
            source = (int)mapItem["EdgeData"][i]["From"];
            dest = (int)mapItem["EdgeData"][i]["To"];
            int edgeno = i + 1;
            GameObject edge = GameObject.Find("E_" + edgeno + "_" + source + "_" + dest);
            string nc = "";

            //checking player inputs for colors
            if (edge.tag == "white")
                nc = "0";
            else if (edge.tag == "AllColor")
                nc = "123";
            else
            {
                if (edge.tag.Contains("red"))
                    nc += '1';
                if (edge.tag.Contains("green"))
                    nc += '2';
                if (edge.tag.Contains("blue"))
                    nc += '3';
            }

            //checking matlab brush file results for this scan
            found_brush = false;
            if(!brush_error)
            {
                string[] brush_info = new string[3];
                foreach(string brush_edge in readBrush)
                {
                    brush_info = brush_edge.Split(',');
                    if((source + "_" + dest) == (brush_info[0] + "_" + brush_info[1]))
                    {
                        switch (brush_info[2])
                        {
                            case "1":
                                brush_map.Add("_" + brush_info[0] + "_" + brush_info[1], "red");
                                break;
                            case "2":
                                brush_map.Add("_" + brush_info[0] + "_" + brush_info[1], "green");
                                break;
                            case "3":
                                brush_map.Add("_" + brush_info[0] + "_" + brush_info[1], "blue");
                                break;
                            case "13":
                                brush_map.Add("_" + brush_info[0] + "_" + brush_info[1], "red+blue");
                                break;
                            case "23":
                                brush_map.Add("_" + brush_info[0] + "_" + brush_info[1], "green+blue");
                                break;
                            case "12":
                                brush_map.Add("_" + brush_info[0] + "_" + brush_info[1], "red+green");
                                break;
                            case "123":
                                brush_map.Add("_" + brush_info[0] + "_" + brush_info[1], "red+blue+green");
                                break;
                            case "":
                                brush_map.Add("_" + brush_info[0] + "_" + brush_info[1], "white");
                                break;
                        }
                        line += ',' + nc + '_' + brush_info[2];
                        found_brush = true;
                        break;
                    }
                }
                //Debug.Log("brushfile found and read");
            }
            //if no matlab brush info found on this edge just add player input
            if(!found_brush)
                line += ',' + nc;
        }

        //equalise on ver with current scan
        Manager.Instance.on_ver = Manager.Instance.scans;

        //reset the file: delete it and set brush to done for brushing update to the edges.
        if(found_brush)
        {
            brush_done = true;
            ver_control_file(scanFile);
        }
        csv.AppendLine(line);

        File.AppendAllText(path, csv.ToString());
    }

    //write down the scan file for version control needs
    private void ver_control_file(string path)
    {
        string log_directory = Application.streamingAssetsPath + "/Database/Input/ver_cntrl";
        if (!Directory.Exists(log_directory))
        {
            Directory.CreateDirectory(log_directory);
        }
        else
        {
            string newpath = log_directory + "/" + Manager.Instance.scans.ToString() + "_Scan.csv";
            File.Move(path, newpath);
            File.Delete(path);
        }
    }

    //hacky way to track when screenshot is shot
    public static void screenshot_done(bool done)
    {
        instance.screenshotdone = done;
    }

    public static bool screenshot()
    {
        return instance.screenshotdone;
    }

    //different values to get the right fit for the screenshot
    public static void takeScreenShot_static(int width, int height, int x, int y, int w, int h, bool scan_pic = false)
    {
        instance.scan_ease_pic = scan_pic;
        instance.takeScreenShot(width , height);

        w_ = w;
        h_ = h;
        x_ = x;
        y_ = y;
    }
}
