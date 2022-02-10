using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class mapBrushing : MonoBehaviour
{
    private static mapBrushing instance;

    private void Awake()
    {
        instance = this;
    }
    //call this for regular brushing map update
    public static void AssignLine(string lineType, string lineName)
    {
        GameObject theSelectedObj = GameObject.Find(lineName);
        GameObject NewObj = GameObject.Find(lineType);

        if (theSelectedObj.tag.Contains("+") && lineType != "white")
        {
            NewObj = GameObject.FindGameObjectWithTag("AllColor");
        }
        else if(theSelectedObj.tag == "white")
        {
            NewObj = GameObject.Find(lineType);
        }
        else if(Manager.Instance.scans > 0 || Manager.Instance.color_start) //we don't want multple contractors on same edge before first scans
        {
            string update = NewObj.tag + theSelectedObj.tag;
            if(NewObj.tag == "white")
                update = "white";
            else if (update.Contains("red") && update.Contains("blue"))
                update = "red+blue";
            else if (update.Contains("red") && update.Contains("green"))
                update = "red+green";
            else if (update.Contains("green") && update.Contains("blue"))
                update = "green+blue";
            else
                update = lineType;

            NewObj = GameObject.Find(update);
        }

        GameObject created = instance.update_it(theSelectedObj, NewObj);
        if (created == null)
            Destroy(created);
        else
            created.name = lineName;

        Manager.Instance.save_map(Manager.Instance.map_version, theSelectedObj);
        Manager.Instance.save_map(Manager.Instance.map_version + 1, created);

        Manager.Instance.edge_changes += 1;

    }

    //call this to undo/redo update the map contractors/coloring
    public static void map_update_undoRedo(Dictionary<string, string> updateEdges)
    {
        foreach (var updateEdge in updateEdges)
        {
            GameObject NewObj = GameObject.Find(updateEdge.Value);
            GameObject theSelectedObj = GameObject.Find(updateEdge.Key);

            GameObject created = instance.update_it(theSelectedObj, NewObj);
            if (created == null)
                Destroy(created);
            else
                created.name = updateEdge.Key;
        }
        Debug.Log("Map Updated undo redo");
    }

    //call this to version update the map contractors/coloring
    public static void map_update_ver(Dictionary<string, string> updateEdges)
    {
        GameObject[] redLine = GameObject.FindGameObjectsWithTag("red");
        GameObject[] greenLine = GameObject.FindGameObjectsWithTag("green");
        GameObject[] blueLine = GameObject.FindGameObjectsWithTag("blue");
        GameObject[] white = GameObject.FindGameObjectsWithTag("white");
        GameObject[] red_blue = GameObject.FindGameObjectsWithTag("red+blue");
        GameObject[] red_green = GameObject.FindGameObjectsWithTag("red+green");
        GameObject[] green_blue = GameObject.FindGameObjectsWithTag("green+blue");
        GameObject[] all_color = GameObject.FindGameObjectsWithTag("AllColor");
        List<GameObject[]> lines_ = new List<GameObject[]>
            {
                redLine, greenLine, blueLine, white, red_blue, red_green, green_blue, all_color
            };

        List<GameObject> allGameObjects = new List<GameObject>();

        foreach(GameObject[] lines in lines_)
        {
            foreach (GameObject line in lines)
                allGameObjects.Add(line);
        }

        foreach (var updateEdge in updateEdges)
        {
            bool objSelected = false;
            string edgeName = updateEdge.Key;

            GameObject NewObj = GameObject.Find(updateEdge.Value);
            GameObject theSelectedObj = null;

            foreach (GameObject go in allGameObjects)
            {
                if (go.name.EndsWith(updateEdge.Key))
                {
                    theSelectedObj = go;
                    edgeName = go.name;
                    objSelected = true;
                    break;
                }
            }

            //if no objected not found GTFO
            if (!objSelected)
            {
                Destroy(theSelectedObj);
                continue;
            }

            GameObject created = instance.update_it(theSelectedObj, NewObj);
            if (created == null)
                Destroy(created);
            else
                created.name = edgeName;
        }
        Debug.Log("Map Updated version control");
    }

    //for new run edge update
    public static void new_run_update(GameObject selectedObj, GameObject newObj)
    {
        GameObject new_run_edge = instance.update_it(selectedObj, newObj);
        if (new_run_edge == null)
            Destroy(new_run_edge);
        else
            new_run_edge.name = selectedObj.name;
    }

    private GameObject update_it(GameObject theSelectedObj, GameObject NewObj)
    {

        Vector3 distance = theSelectedObj.transform.localScale;

        Vector3 objScale = theSelectedObj.transform.localScale;
        Vector3 between2 = theSelectedObj.transform.position;
        Quaternion tetha = theSelectedObj.transform.rotation;

        // make sure you are deleting a line
        string objectName = theSelectedObj.name;
        if (objectName.Contains("E_"))
        {
            Destroy(theSelectedObj);
            GameObject created = Instantiate(NewObj, between2, Quaternion.identity);
            created.transform.rotation = tetha;//Rotate (startPoint, tetha);
            created.transform.parent = GameObject.Find("MapScreen").gameObject.transform;
            created.transform.localScale = distance;
            return created;
        }
        return null;
    }
}
