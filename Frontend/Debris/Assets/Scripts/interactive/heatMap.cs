using UnityEngine;
using System.Collections;

public class heatMap : MonoBehaviour
{
    public GameObject legend, help_legend;

    public void toggle_heatmap()
    {
        GameObject[] heats = GameObject.FindGameObjectsWithTag("heat");

        if (legend.activeSelf)
        {
            foreach (GameObject heat in heats)
            {
                heat.GetComponent<SpriteRenderer>().maskInteraction = SpriteMaskInteraction.VisibleInsideMask;
                legend.SetActive(false);
            }
            Manager.Instance.debris_check += 1;
        }
        else
        {
            foreach (GameObject heat in heats)
            {
                heat.GetComponent<SpriteRenderer>().maskInteraction = SpriteMaskInteraction.None;
                legend.SetActive(true);
            }

            string active = gameObject.GetComponent<map_transformations>().active_eye();

            if(active != "none")
            {
                gameObject.GetComponent<map_transformations>().edge_mask(GameObject.Find(active));
            }
        }
    }

    //put it here coz debris also has legend toggling on and off.
    public void toggle_help()
    {
        if (help_legend.activeSelf)
        {
            help_legend.SetActive(false);
        }
        else
        {
            help_legend.SetActive(true);
        }
    }
}
