using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AssetBundleManager : MonoBehaviour
{
    //单例模块
    private static AssetBundleManager instance;
    public static AssetBundleManager Instance
    {
        get
        {
            if (instance == null)
            {
                GameObject obj = new GameObject("AssetBundleManager");
                DontDestroyOnLoad(obj);
                instance = obj.AddComponent<AssetBundleManager>();
            }
            return instance;
        }
    }

    //存储所有加载过的AB包的容器
    private Dictionary<string, AssetBundle> abDic = new Dictionary<string, AssetBundle>();
    //主包，只会加载一次
    private AssetBundle mainAB = null;
    //获取依赖包的配置文件
    private AssetBundleManifest manifest = null;

    //ab包存放的路径，方便修改
    private string PathUrl
    {
        get
        {
            return Application.streamingAssetsPath + "/";
        }
    }
    //主包名，根据平台不同而不同
    private string MainABName
    {
        get
        {
#if UNITY_IOS
            return "IOS";
#elif UNITY_ANDROID
            return "Android";
#else 
            return "PC";
#endif
        }
    }

    /// <summary>
    /// 加载资源，同步加载，3种方法重载
    /// </summary>
    /// <param name="abName"></param>
    /// <param name="resName"></param>
    public Object LoadRes(string abName, string resName)
    {
        LoadAB(abName);

        Object obj = abDic[abName].LoadAsset(resName);
        //如果是GameObject，加载后基本都是创建游戏物体，所以这里判断一下如果是GameObject，直接返回创建好的游戏物体
        if (obj is GameObject)
            return Object.Instantiate(obj);
        else
            return obj;
    }
    public Object LoadRes(string abName, string resName, System.Type type)
    {
        LoadAB(abName);

        Object obj = abDic[abName].LoadAsset(resName, type);
        //如果是GameObject，加载后基本都是创建游戏物体，所以这里判断一下如果是GameObject，直接返回创建好的游戏物体
        if (obj is GameObject)
            return Object.Instantiate(obj);
        else
            return obj;
    }
    public T LoadRes<T>(string abName, string resName) where T : Object
    {
        LoadAB(abName);

        T t = abDic[abName].LoadAsset<T>(resName);
        //如果是GameObject，加载后基本都是创建游戏物体，所以这里判断一下如果是GameObject，直接返回创建好的游戏物体
        if (t is GameObject)
            return Object.Instantiate(t);
        else
            return t;
    }

    /// <summary>
    /// 加载资源，异步加载，3种方法重载
    /// </summary>
    /// <param name="abName"></param>
    /// <param name="resName"></param>
    /// <returns></returns>
    public void LoadResAsync(string abName, string resName, System.Action<Object> callBack)
    {
        StartCoroutine(ReallyLoadResAsync(abName, resName, callBack));
    }
    private IEnumerator ReallyLoadResAsync(string abName, string resName, System.Action<Object> callBack)
    {
        yield return StartCoroutine(LoadABAsync(abName));

        AssetBundleRequest abr = abDic[abName].LoadAssetAsync(resName);
        yield return abr;

        //如果是GameObject，加载后基本都是创建游戏物体，所以这里判断一下如果是GameObject，直接创建好游戏物体
        if (abr.asset is GameObject)
            callBack(Instantiate(abr.asset));
        else
            callBack(abr.asset);
    }
    public void LoadResAsync(string abName, string resName, System.Type type, System.Action<Object> callBack)
    {
        StartCoroutine(ReallyLoadResAsync(abName, resName, type, callBack));
    }
    private IEnumerator ReallyLoadResAsync(string abName, string resName, System.Type type, System.Action<Object> callBack)
    {
        yield return StartCoroutine(LoadABAsync(abName));

        AssetBundleRequest abr = abDic[abName].LoadAssetAsync(resName, type);
        yield return abr;

        //如果是GameObject，加载后基本都是创建游戏物体，所以这里判断一下如果是GameObject，直接创建好游戏物体
        if (abr.asset is GameObject)
            callBack(Instantiate(abr.asset));
        else
            callBack(abr.asset);
    }
    public void LoadResAsync<T>(string abName, string resName, System.Action<T> callBack) where T : Object
    {
        StartCoroutine(ReallyLoadResAsync<T>(abName, resName, callBack));
    }
    private IEnumerator ReallyLoadResAsync<T>(string abName, string resName, System.Action<T> callBack) where T : Object
    {
        yield return StartCoroutine(LoadABAsync(abName));

        AssetBundleRequest abr = abDic[abName].LoadAssetAsync<T>(resName);
        yield return abr;

        //如果是GameObject，加载后基本都是创建游戏物体，所以这里判断一下如果是GameObject，直接创建好游戏物体
        if (abr.asset is GameObject)
            callBack(Instantiate(abr.asset) as T);
        else
            callBack(abr.asset as T);
    }

    /// <summary>
    /// 同步加载依赖包和资源包
    /// </summary>
    /// <param name="abName"></param>
    private void LoadAB(string abName)
    {
        //先加载依赖包，再加载AB包，最后加载文件
        if (mainAB == null)
        {
            mainAB = AssetBundle.LoadFromFile(PathUrl + MainABName);
            manifest = mainAB.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        }

        string[] strs = manifest.GetAllDependencies(abName);
        for (int i = 0; i < strs.Length; i++)
        {
            if (!abDic.ContainsKey(strs[i]))
                abDic.Add(strs[i], AssetBundle.LoadFromFile(PathUrl + strs[i]));
        }

        //没有包加载包，有包直接取出来使用
        if (!abDic.ContainsKey(abName))
            abDic.Add(abName, AssetBundle.LoadFromFile(PathUrl + abName));
    }
    /// <summary>
    /// 异步加载依赖包和资源包
    /// </summary>
    /// <param name="abName"></param>
    /// <returns></returns>
    private IEnumerator LoadABAsync(string abName)
    {
        //先加载依赖包，再加载AB包，最后加载文件
        if (mainAB == null)
        {
            AssetBundleCreateRequest createRequest = AssetBundle.LoadFromFileAsync(PathUrl + MainABName);
            yield return createRequest;
            mainAB = createRequest.assetBundle;

            AssetBundleRequest request = mainAB.LoadAssetAsync<AssetBundleManifest>("AssetBundleManifest");
            yield return request;
            manifest = request.asset as AssetBundleManifest;
        }

        string[] strs = manifest.GetAllDependencies(abName);
        for (int i = 0; i < strs.Length; i++)
        {
            if (!abDic.ContainsKey(strs[i]))
            {
                AssetBundleCreateRequest createRequest = AssetBundle.LoadFromFileAsync(PathUrl + strs[i]);
                yield return createRequest;
                abDic.Add(strs[i], createRequest.assetBundle);
            }
        }

        //没有包加载包，有包直接取出来使用
        if (!abDic.ContainsKey(abName))
            abDic.Add(abName, AssetBundle.LoadFromFile(PathUrl + abName));
    }

    /// <summary>
    /// 卸载单个包
    /// </summary>
    /// <param name="abName"></param>
    public void UnLoad(string abName)
    {
        if (abDic.ContainsKey(abName))
        {
            abDic[abName].Unload(false);
            abDic.Remove(abName);
        }

    }

    /// <summary>
    /// 卸载所有包
    /// </summary>
    public void ClearAssetBundles()
    {
        AssetBundle.UnloadAllAssetBundles(false);
        abDic.Clear();
        mainAB = null;
        manifest = null;
    }
}
