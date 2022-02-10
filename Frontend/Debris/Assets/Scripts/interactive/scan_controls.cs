using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;
using UnityEngine.UI;
using System.IO;

public class scan_controls : MonoBehaviour
{
    public Button profit_button, time_button, intersect_button;
    public Sprite[] profit_sprite, time_sprite, intersect_sprite;
    private int profit_obj, time_obj, intersect_obj, total;

    public Dropdown which_run;
    public GameObject scan, mapscreen, verControl,manager;
    public GameObject[] blinkers = new GameObject[3];

    [Header("screenshot setting")]
    public int wid;
    public int hght, w, h, x, y;

    //checking scans and cursor size
    private int scanned;
    private float playTime;

    private bool rerun = false;

    private void Awake()
    {
        scanned = 0;

        playTime = 0;

        profit_obj = 0;
        time_obj = 0;
        intersect_obj = 0;
        total = 0;

        Manager.Instance.reset_game();
        update_runList();
    }

    private void Start()
    {
        GameObject[] themWhiteEdges = GameObject.FindGameObjectsWithTag("white");

        if (themWhiteEdges.Length <= 1)
        {
            manager.GetComponent<graph_view>().toggle_noti();

            if(manager.GetComponent<contInfo_Matlab>().run_generatecnc())
                rerun = true;
        }
    }

    private void Update()
    {
        //track playtime
        playTime += Time.deltaTime;

        if (Input.GetMouseButtonUp(0) && Manager.Instance.flag)
        {
            //Debug.Log("update " + Manager.Instance.flag);

            Manager.Instance.map_version += 1;
            Manager.Instance.flag = false;

            deborah_check();
        }

        if (scanned != Manager.Instance.scans || rerun)
        {
            scanned = Manager.Instance.scans;
            deborah_check();
        }

        //hacky way to make sure order of things for new run
        if (runSetup.screenshot())
        {
            runSetup.screenshot_done(false);
            verControl.GetComponent<ver_control>().empty_folder(true);

            //run generate contractor via matlab for non scratch level
            GameObject[] themWhiteEdges = GameObject.FindGameObjectsWithTag("white");
            if (themWhiteEdges.Length <= 1)
            {
                manager.GetComponent<graph_view>().toggle_noti();
                manager.GetComponent<contInfo_Matlab>().run_generatecnc();
            }
            rerun = true;
            check_deborah();
        }
    }

    private void update_runList()
    {
        string dir = Application.streamingAssetsPath + "/Database/Output/" + Manager.Instance.playerId + "_" + Manager.Instance.sessionId;

        if (!Directory.Exists(dir))
        {
            Debug.Log("no folder found to keep current run logs in");
            return;
        }
        else
        {
            System.IO.DirectoryInfo di = new DirectoryInfo(dir);

            //update the run list drop down box
            which_run.ClearOptions();
            List<string> dropOptions = new List<string>();
            dropOptions.Add("Current");
            foreach (FileInfo file in di.GetFiles())
            {
                if (file.Name.EndsWith(".csv"))
                {
                    dropOptions.Add(file.Name.Substring(0,file.Name.IndexOf(".csv")));
                }
            }
            which_run.AddOptions(dropOptions);

        }
    }

    public void check_deborah()
    {
        //manual call to check when clicking scan objects after coloring edges
        deborah_check(true);
    }

    private void deborah_check(bool obj = false)
    {
        GameObject[] themWhiteLines = GameObject.FindGameObjectsWithTag("white");

        if (Manager.Instance.edge_changes > 40 || (themWhiteLines.Length > 1 && Manager.Instance.scans < 1))
        {
            if (rerun)
            {
                foreach (GameObject blinker in blinkers)
                    blinker.GetComponent<Toggle>().interactable = true;
            }
            else
            {
                foreach (GameObject blinker in blinkers)
                    blinker.GetComponent<Toggle>().interactable = false;
            }
        }
        else
        {
            foreach (GameObject blinker in blinkers)
                blinker.GetComponent<Toggle>().interactable = true;
        }

        if (profit_obj == 1 || time_obj == 1 || intersect_obj ==1)
        {
            //checks to see if scan should be active or not
            bool noscan = false;
            if (obj)
                noscan = false;
            else if (Manager.Instance.edge_changes < 2)
                noscan = true;

            if (noscan || (themWhiteLines.Length > 1 && Manager.Instance.scans < 1 && !rerun) || themWhiteLines.Length > 120)
            {
                scan.GetComponent<Button>().interactable = false;
            }
            else if (scan.GetComponent<Button>().interactable == false)
            {
                scan.GetComponent<Button>().interactable = true;
            }
        }
        else
        {
            scan.GetComponent<Button>().interactable = false;
        }

        rerun = false;
    }

    //bunch of checks for making the input buttons function
    public void profit_check()
    {
        if (profit_obj == 1)
        {
            total--;
            profit_obj = 0;
        }
        else if (total < 2)
        {
            total++;
            profit_obj = 1;
        }

        update_button(profit_button, profit_sprite, profit_obj);
    }

    public void time_check()
    {
        if (time_obj == 1)
        {
            total--;
            time_obj = 0;
        }
        else if (total < 2)
        {
            total++;
            time_obj = 1;
        }

        update_button(time_button, time_sprite, time_obj);
    }

    public void intersect_check()
    {
        if (intersect_obj == 1)
        {
            total--;
            intersect_obj = 0;
        }
        else if(total < 2)
        {
            total++;
            intersect_obj = 1;
        }

        update_button(intersect_button, intersect_sprite, intersect_obj);
    }

    //public method to call scanning functionality
    public void scan_check()
    {
        //only update playtime right after scan is hit
        Manager.Instance.time_played = playTime;

        //at this point on_ver and scans are always same, 
        //scan is updated in read contractor and then both these variables even out in logging
        //if they are not the same it means we went back to a different version and should empty out ver control when scanned
        if (Manager.Instance.on_ver != Manager.Instance.scans)
            verControl.GetComponent<ver_control>().empty_folder();

        runSetup.takeScreenShot_static(wid, hght, 0, 0, 0, 0, true); // take scan pic for experiment analysis accessibility
        manager.GetComponent<graph_view>().toggle_noti();
        manager.GetComponent<contInfo_Matlab>().read_contractor_info(profit_obj, time_obj, intersect_obj);
        Manager.Instance.color_start = false;
    }

    //submit the current run and log it down.
    public void submit_log()
    {
        string player, session;
        if (Manager.Instance.sessionId == "" || Manager.Instance.playerId == "")
        {
            player = "def";
            session = "def";
        }
        else
        {
            player = Manager.Instance.playerId;
            session = Manager.Instance.sessionId;
        }
        string exPath = Application.streamingAssetsPath + "/Database/Output/" + player + "_" + session + "/Run_" + Manager.Instance.run.ToString() + ".csv";
        runSetup.log_data(exPath, profit_obj, time_obj, intersect_obj);

        new_run();
    }

    public void finalise_run()
    {
        //checkpath and print fota
        string path = Application.streamingAssetsPath + "/Database/Output/" + Manager.Instance.playerId + "_" + Manager.Instance.sessionId + "/";
        if (which_run.options[which_run.value].text == "Current")
        {
            try
            {
                path += "Run_" + Manager.Instance.run.ToString() + ".csv";
            }
            catch
            {
                Debug.Log("can't finalise without atleast one scan");
            }
        }
        else
        {
            path += which_run.options[which_run.value].text + ".csv";
        }
        string newpath = path.Substring(0, path.IndexOf(".csv")) + "_Final.csv";

        //change name of the finalise run file to mark it as finalise then quit game.
        File.Move(path, newpath);
        File.Delete(path);

        //reset game; everything reset
        Manager.Instance.run = 0;
        Manager.Instance.reset_game();

        SceneManager.LoadScene("HomeMenu");
    }

    //new run DO: redraw map;restart graphs; scan = 0; vercontrl reset; 
    private void new_run()
    {
        runSetup.takeScreenShot_static(wid, hght, x, y, w, h);

        mapscreen.GetComponent<Map_Initiation>().drawMap_again();
        //some steps in update hacky fix
        //mapscreen.GetComponent<Map_Initiation>().drawMap_again();
        //verControl.GetComponent<ver_control>().empty_folder(true);

        update_runList();

        //new run; everything else reset
        Manager.Instance.run += 1;
        Manager.Instance.reset_game();
        runSetup.reset_header();
    }

    private void update_button(Button butt, Sprite[] spri, int pressed)
    {
        if (pressed == 1)
            butt.GetComponent<Image>().sprite = spri[0];
        else
            butt.GetComponent<Image>().sprite = spri[1];
    }
}
