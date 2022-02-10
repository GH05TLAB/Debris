using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class undo_redo : MonoBehaviour
{
    int undo_count = 0; 

    //reset stuff
    public void reset_count_moves()
    {
        Manager.Instance.map_version = 0;
        Manager.Instance.map_info.Clear();
    }

    //redo button call
    public void redo()
    {
        if (Manager.Instance.map_version < undo_count && Manager.Instance.map_info.Count>1)
        {
            Manager.Instance.map_version++;
            mapBrushing.map_update_undoRedo(Manager.Instance.map_info[Manager.Instance.map_version]);
        }
        else if(Manager.Instance.map_info.Count > 1)
        {
            undo_count = 0;
        }
    }

    //undo button call 
    public void undo()
    {
        if (Manager.Instance.map_version > 0)
        {
            Manager.Instance.map_version--;
            mapBrushing.map_update_undoRedo(Manager.Instance.map_info[Manager.Instance.map_version]);
            undo_count++;
        }
    }
}