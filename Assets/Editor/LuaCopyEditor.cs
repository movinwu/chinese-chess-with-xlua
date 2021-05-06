using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;

public class LuaCopyEditor : Editor
{        
    //lua文件路径
    private static string luaPath = Application.dataPath + "/Lua/";
    //存储的txt文件路径
    private static string txtPath = Application.dataPath + "/LuaTxt/";


    [MenuItem("XLua//Copy lua to txt file")]
    public static void CopyLuaToTxtFile(){

        //校验新路径文件是否存在
        if(!Directory.Exists(txtPath))
        //不存在创建
            Directory.CreateDirectory(txtPath);
        else{
            //存在清空文件夹
            string[] oldFiles = Directory.GetFiles(txtPath);
            for(int i = 0;i < oldFiles.Length;i ++)
                File.Delete(oldFiles[i]);
        }
        //调用根据地址复制并打包的方法
        CopyLuaToTxtFile(luaPath);

        //刷新Unity
        AssetDatabase.Refresh();

        //修改AB包打包
        string[] txtFilePaths = Directory.GetFiles(txtPath);
        for(int i = 0;i < txtFilePaths.Length;i ++){
            AssetImporter importer = AssetImporter.GetAtPath(txtFilePaths[i].Substring(txtFilePaths[i].IndexOf("Assets")));
            if(importer != null)
                importer.assetBundleName = "lua";
        }
    }

    /// <summary>
    /// 根据地址复制lua文件的方法
    /// </summary>
    /// <param name="path"></param>
    private static void CopyLuaToTxtFile(string path){
        //校验路径是否存在
        if(!Directory.Exists(path))
            return;

        //找一找当前文件夹中是否还有文件夹，有的话递归
        string[] directories = Directory.GetDirectories(path);
        if(directories.Length > 0){
            for(int i = 0;i < directories.Length;i ++){
                CopyLuaToTxtFile(directories[i]);
            }
        }

        //得到每个lua文件路径
        string[] luaFiles = Directory.GetFiles(path,"*.lua");

        //遍历拷贝
        string tempPath = "";
        if(luaFiles.Length > 0)
            for(int i = 0;i < luaFiles.Length;i++){
                //先遍历修改以下路径名，GetFiles得到的路径是拼接的，有的/有的\
                StringBuilder builder = new StringBuilder(luaFiles[i]);
                for (int j = 0;j < builder.Length;j ++)
                    if(builder[j].Equals('\\'))
                        builder[j] = '/';
                string correctPath = builder.ToString();
                //得到新路径
                tempPath = txtPath + correctPath.Substring(correctPath.LastIndexOf("/")+1) + ".txt";
                File.Copy(correctPath,tempPath);
            }
    }
}
