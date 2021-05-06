using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using XLua;

/// <summary>
/// lua管理器，对lua解析器的进一步封装，保证lua解析器的唯一性
/// </summary>
public class LuaManager
{
    //单例模块
    private static LuaManager instance;
    public static LuaManager Instance
    {
        get
        {
            if (instance == null)
                instance = new LuaManager();
            return instance;
        }
    }
    private LuaManager()
    {
        //在构造方法中就为唯一的lua解析器赋值
        luaEnv = new LuaEnv();
        //加载lua脚本重定向
        //重定向到lua文件夹下
        luaEnv.AddLoader((ref string filePath) =>
        {
            //用于存储读取结果的数组
            byte[] fileContent = null;
            //拼接lua文件夹的位置
            string path = Application.dataPath + "/Lua/";
            //调用自定义方法读取lua文件
            if(TryGetLoadFile(path,ref fileContent,filePath))
                return fileContent;
            return null;
        });
        //重定向加载AB包中的lua脚本
        luaEnv.AddLoader((ref string filePath) =>
        {
            /*//加载AB包
            string path = Application.streamingAssetsPath + "/lua";
            AssetBundle bundle = AssetBundle.LoadFromFile(path);

            //加载lua文件，返回
            TextAsset texts = bundle.LoadAsset<TextAsset>(filePath + ".lua");
            //返回加载到的lua文件的byte数组
            return texts.bytes;*/

            /*//使用AB包管理器加载，异步加载，这段代码会始终返回空，因为还没等异步加载完成已经返回了，lua也不适合异步加载，不要使用
            byte[] luaBytes = null;
            AssetBundleManager.Instance.LoadResAsync<TextAsset>("lua", filePath + ".lua", (lua) =>
            {
                 if (lua != null)
                     luaBytes = lua.bytes;
                 else
                     Debug.Log("重定向失败，从AB包加载lua文件失败");
             });
            return luaBytes;*/

            //使用AB包管理器加载，同步加载
            TextAsset texts = AssetBundleManager.Instance.LoadRes<TextAsset>("lua", filePath + ".lua");
            if (texts != null)
                return texts.bytes;
            else
                Debug.Log("从AB包加载lua文件失败，文件名是" + filePath);

            return null;

        });
    }

    //持有一个唯一的lua解析器
    private LuaEnv luaEnv;

    //luaEnv中的大G表，提供给外部调用
    public LuaTable Global
    {
        get
        {
            //校验一下instance是否是null，避免dispose后无法获取的情况出现
            if (instance == null)
                instance = new LuaManager();
            return luaEnv.Global;
        }
    }

    /// <summary>
    /// 执行单句lua代码
    /// </summary>
    /// <param name="luaCodeString"></param>
    public void DoString(string luaCodeString)
    {
        luaEnv.DoString(luaCodeString);
    }
    /// <summary>
    /// 执行lua文件的代码，直接提供文件名即可执行文件，不需要再书写lua的require语句，在方法内部拼接lua语句
    /// </summary>
    /// <param name="fileName">lua文件名</param>
    public void DoLuaFile(string fileName)
    {
        luaEnv.DoString("require('" + fileName + "')");
    }
    /// <summary>
    /// 释放解析器
    /// </summary>
    public void Tick()
    {
        luaEnv.Tick();
    }
    /// <summary>
    /// 销毁解析器
    /// </summary>
    public void Dispose()
    {
        luaEnv.Dispose();
        //销毁解析器后将lua解析器对象和单例变量都置空，下次调用时会自动调用构造函数创建lua解析器，以免报空
        luaEnv = null;
        instance = null;
    }

    /// <summary>
    /// 用于重定向读取lua文件的方法，使用递归读取Lua文件夹下的子文件夹
    /// </summary>
    /// <param name="path">文件夹路径</param>
    /// <param name="fileContent">存储读取结果的数组</param>
    /// <param name="filePath">lua文件的名称</param>
    /// <returns></returns>
    private bool TryGetLoadFile(string path,ref byte[] fileContent,string filePath){
        //读取当前文件夹下的文件夹
        string[] directories = Directory.GetDirectories(path);
        //有文件夹的情况下遍历这些文件夹依次递归
        if(directories.Length > 0)
            for(int i = 0;i < directories.Length;i++)
                //递归，如果读取到了文件，则返回
                if(TryGetLoadFile(directories[i],ref fileContent,filePath))
                    return true;
        
        //递归在子文件夹下读取到了文件，下面代码不会执行，如果没有递归读取到，再执行下面的代码
        //下面的代码获取当前文件夹下的文件并读取文件

        //拼接完整的lua文件所在路径
        path = path + "/" + filePath + ".lua";
        //判断文件是否存在，存在返回读取的文件字节数组，不存在打印提醒信息，返回null
        if (File.Exists(path))
        {
            fileContent = File.ReadAllBytes(path);
            Debug.Log("Lua文件夹重定向成功，文件路径为" + path);
            return true;
        }
        else
        {
            Debug.Log("Lua文件夹重定向失败，文件路径为" + path);
            return false;
        }
    }
}
