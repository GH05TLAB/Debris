using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;
using UnityEngine.UI;

public class graph_view : MonoBehaviour {

    GameObject intersect_view;
    GameObject mapscreen;

    public GameObject onCursor, submit_button;
    public GameObject scan, error, run_image, handle_mark;
    public Text current_intersect_text;
    private Texture2D image_tex;

    private List<GameObject> intersect_marks = new List<GameObject>();

    private void Awake()
    {
        mapscreen = GameObject.Find("MapScreen");
        intersect_view = GameObject.Find("intersection_overlaps");

        //keep the texture empty
        image_tex = null;
        scan_disable();
    }

    private void Update()
    {
        if(scan.activeSelf)
        {
            if(runSetup.get_brush_done())
            {

                runSetup.set_brush_done(false);
                mapBrushing.map_update_ver(runSetup.get_brush_map());
                scan.SetActive(false);
            }
            else if(!runSetup.get_found_brush())
            {
               // Debug.Log("matlab brush info not found");
                //scan.SetActive(false);
            }
        }
    }

    public void toggle_noti()
    {
        GameObject[] themWhiteLines = GameObject.FindGameObjectsWithTag("whiteLine");
        if (themWhiteLines.Length > 1 && Manager.Instance.scans< 1)
        {
            scan_disable();
        }
        else
        {
            scan.SetActive(true);
            GameObject[] blinkers = GameObject.FindGameObjectsWithTag("toggle");

            foreach (GameObject blinker in blinkers)
                blinker.GetComponent<Toggle>().interactable = false;
        }
    }

    private void scan_disable()
    {
        GameObject scan = GameObject.Find("Scan");
        GameObject[] blinkers = GameObject.FindGameObjectsWithTag("toggle");

        scan.GetComponent<Button>().interactable = false;

        foreach (GameObject blinker in blinkers)
            blinker.GetComponent<Toggle>().interactable = false;
    }

    //update the graphs and then call function to write up the log for experiment stuff, also reset suggest
    public void update_log(bool scanning, int profit_obj, int time_obj, int intersect_obj)
    {
        if (scanning)
        {
            string exPath = Application.streamingAssetsPath + "/Database/Output/" + Manager.Instance.playerId + "_" + Manager.Instance.sessionId + "/Run_" + Manager.Instance.run.ToString() + ".csv";
            runSetup.log_data(exPath, profit_obj, time_obj, intersect_obj);

            update_graphs();
            update_verCont();

            //scanning done so reset suggest count for next logging.
            Manager.Instance.suggest = new int[] { 0, 0, 0 };
        }
        //scan.SetActive(false);
    }

//work the dropdown
public void update_run_image(Dropdown op)
    {
        string input = op.options[op.value].text;

        string exPath = Application.persistentDataPath + "/run_images/" + input + ".png";
        byte[] image;

        if (input.ToString() != "Current")
        {
            image = runSetup.read_image(exPath);

            image_tex = new Texture2D(0, 0, TextureFormat.RGBAFloat, false);
            image_tex.LoadImage(image);

            mapscreen.SetActive(false);
            run_image.SetActive(true);
            run_image.GetComponent<RectTransform>().sizeDelta = new Vector2(image_tex.width, image_tex.height);
            run_image.GetComponent<RawImage>().texture = image_tex;
        }
        else
        {
            mapscreen.SetActive(true);
            run_image.SetActive(false);
            image_tex = null;
        }
    }

    //controller to open and close graphs
    public void expand_graph(GameObject graph)
    {
        Animator graph_anim = graph.GetComponent<Animator>();
        Animator map_anim = mapscreen.GetComponent<Animator>();

        map_anim.GetComponent<Animator>().enabled = true;

        if (graph.name.Contains("_time"))
        {
            GameObject.Find("current_profit").GetComponent<Animator>().SetInteger("profit_state", 1);
            GameObject.Find("current_total").GetComponent<Animator>().SetInteger("progress_state", 1);
            GameObject.Find("intersection_overlaps").GetComponent<Animator>().SetInteger("intersect_state", 1);

            if (graph_anim.GetInteger("time_state") == 2)
            {
                graph_anim.SetInteger("time_state", 1);
                map_anim.SetInteger("map_state", 1);
                onCursor.SetActive(true);
                submit_button.GetComponent<Button>().interactable = true;
            }
            else
            {
                graph_anim.SetInteger("time_state", 2);
                map_anim.SetInteger("map_state", 3);
                onCursor.SetActive(false);
                submit_button.GetComponent<Button>().interactable = false;
            }
        }
        else if(graph.name.Contains("_profit"))
        {
            GameObject.Find("current_time").GetComponent<Animator>().SetInteger("time_state", 1);
            GameObject.Find("current_total").GetComponent<Animator>().SetInteger("progress_state", 1);
            GameObject.Find("intersection_overlaps").GetComponent<Animator>().SetInteger("intersect_state", 1);

            if (graph_anim.GetInteger("profit_state") == 2)
            {
                graph_anim.SetInteger("profit_state", 1);
                map_anim.SetInteger("map_state", 1);
                onCursor.SetActive(true);
                submit_button.GetComponent<Button>().interactable = true;
            }
            else
            {
                graph_anim.SetInteger("profit_state", 2);
                map_anim.SetInteger("map_state", 2);
                onCursor.SetActive(false);
                submit_button.GetComponent<Button>().interactable = false;
            }
        }
        else if(graph.name.Contains("_total"))
        {
            GameObject.Find("current_profit").GetComponent<Animator>().SetInteger("profit_state", 1);
            GameObject.Find("current_time").GetComponent<Animator>().SetInteger("time_state", 1);
            GameObject.Find("intersection_overlaps").GetComponent<Animator>().SetInteger("intersect_state", 1);

            if (graph_anim.GetInteger("progress_state") == 2)
            {
                graph_anim.SetInteger("progress_state", 1);
                map_anim.SetInteger("map_state", 1);
                onCursor.SetActive(true);
                submit_button.GetComponent<Button>().interactable = true;
            }
            else
            {
                graph_anim.SetInteger("progress_state", 2);
                map_anim.SetInteger("map_state", 4);
                onCursor.SetActive(false);
                submit_button.GetComponent<Button>().interactable = false;
            }
        }
        else if(graph.name == "intersection_overlaps")
        {
            GameObject.Find("current_profit").GetComponent<Animator>().SetInteger("profit_state", 1);
            GameObject.Find("current_time").GetComponent<Animator>().SetInteger("time_state", 1);
            GameObject.Find("current_total").GetComponent<Animator>().SetInteger("progress_state", 1);

            if (graph_anim.GetInteger("intersect_state") == 2)
            {
                graph_anim.SetInteger("intersect_state", 1);
                map_anim.SetInteger("map_state", 1);
                onCursor.SetActive(true);
                submit_button.GetComponent<Button>().interactable = true;
            }
            else
            {
                graph_anim.SetInteger("intersect_state", 2);
                map_anim.SetInteger("map_state", 5);
                onCursor.SetActive(false);
                submit_button.GetComponent<Button>().interactable = false;
            }
        }
    }

    public void destroy_some_inter_marks()
    {
        foreach (GameObject mark in intersect_marks)
            Destroy(mark);

        intersect_marks.Clear();
    }

    public void destroy_inter_marks()
    {
        foreach (GameObject mark in intersect_marks)
            Destroy(mark);

        intersect_marks.Clear();
    }

    public void slider_textVal_update(Text val)
    {
        Slider intersect_slider = intersect_view.GetComponentInChildren<Slider>();
        val.text = intersect_slider.value.ToString();
    }

    public void intersection_update(float intersect, bool reupdate = false)
    {
        Text text = intersect_view.GetComponentInChildren<Text>();
        Slider intersect_slider = intersect_view.GetComponentInChildren<Slider>();

        if (text.name == "total nodes")
        {
            text.text = ((GameObject.FindGameObjectsWithTag("objNode").Length-1)*2).ToString();
        }

        intersect_slider.maxValue = (GameObject.FindGameObjectsWithTag("objNode").Length-1)*2;
        intersect_slider.value = intersect;
        current_intersect_text.text = intersect_slider.value.ToString();

        if(!reupdate)
        {
            foreach(GameObject mks in intersect_marks)
            {
                if (intersect_slider.handleRect.position.magnitude - 10 < mks.transform.position.magnitude && mks.transform.position.magnitude < intersect_slider.handleRect.position.magnitude + 10 )
                {
                    mks.GetComponentInChildren<Text>().text += "\n" + Manager.Instance.scans.ToString();
                    return;
                }
            }
            GameObject mark = Instantiate(handle_mark);
            mark.GetComponent<Image>().color = Color.yellow;
            mark.transform.position = intersect_slider.handleRect.position;
            mark.transform.SetParent(intersect_slider.fillRect.transform);
            mark.GetComponentInChildren<Text>().text = Manager.Instance.scans.ToString();
            intersect_marks.Add(mark);
        }
    }

    private void update_graphs()
    {
        GameObject.Find("current_time").GetComponent<BarChart>().update_graph();
        GameObject.Find("current_profit").GetComponent<BarChart>().update_graph();
        GameObject.Find("current_total").GetComponent<LineChart>().update_graph();

        intersection_update(Manager.Instance.intersect);
    }

    //just update version control scores every scan
    private void update_verCont()
    {
        GameObject.Find("ver_control").GetComponent<ver_control>().update_verList(false);
    }

    public void error_msg_open()
    {
        scan.SetActive(false);
        mapscreen.SetActive(false);
        error.SetActive(true);
    }

    public void error_confirm()
    {
        SceneManager.LoadScene("HomeMenu");
    }
}
