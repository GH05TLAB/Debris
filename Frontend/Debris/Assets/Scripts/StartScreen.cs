using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System.IO;
using System;

public class StartScreen : MonoBehaviour {

    public GameObject player_info, session_info, notification;
    public Dropdown dropdown_game;

    private void Awake()
    {
        Cursor.visible = true;
        //get the options setup
        string setup = Application.streamingAssetsPath + "/Database/Input/res_setup/setup_1.txt";

        List<string> dropOptions = new List<string>();
        if (!File.Exists(setup))
        {
            notification.SetActive(true);
        }
        else
        {
            string[] lines = File.ReadAllLines(setup);

            foreach (string line in lines)
            {
                dropOptions.Add(line);
            }
        }

        dropdown_game.ClearOptions();
        dropdown_game.AddOptions(dropOptions);

        Manager.Instance.map_json = "";
    }

    public void StartGame()
    {
        if(player_info.GetComponent<InputField>().text == "" || session_info.GetComponent<InputField>().text == "")
        {
            Manager.Instance.playerId   =   "def";
            Manager.Instance.sessionId  =   "def";
        }
        else
        {
            Manager.Instance.playerId = player_info.GetComponent<InputField>().text;
            Manager.Instance.sessionId = session_info.GetComponent<InputField>().text;
        }

        string log_directory = Application.streamingAssetsPath + "/Database/Output/" + Manager.Instance.playerId + "_" + Manager.Instance.sessionId;

        if(!Directory.Exists(log_directory))
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

        SceneManager.LoadScene("MainGame");
    }
    public void ExitGame() 
    {
        Debug.Log("EXIT!");
        Application.Quit();
    }

    public void select_game()
    {
        Manager.Instance.map_json = Application.streamingAssetsPath + "/Database/Input/" + dropdown_game.GetComponentInChildren<Text>().text + ".json";
    }
}
