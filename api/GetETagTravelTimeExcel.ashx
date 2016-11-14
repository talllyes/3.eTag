<%@ WebHandler Language="C#" Class="GetExcel" %>

using System;
using System.Web;
using System.Net;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;
using KaiValid;
using KaiClass;
using NPOI;
using NPOI.HSSF.UserModel;
using NPOI.XSSF.UserModel;
using NPOI.SS.UserModel;
using System.IO;
using System.Threading.Tasks;

public class GetExcel : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{

    public void ProcessRequest(HttpContext context)
    {
        DataClassesDataContext DB = new DataClassesDataContext();
        string type = context.Items["type"].ToString();
        string str = new System.IO.StreamReader(context.Request.InputStream).ReadToEnd();
        if (type.Equals("分時旅行時間報表"))
        {
            int reportID = Int32.Parse(context.Request["id"].ToString());
            string te = (from a in DB.Report
                         where a.ReportID == reportID
                         select a.Context).FirstOrDefault();
            List<Excel1> excelJson = JsonConvert.DeserializeObject<List<Excel1>>(te);



            ExcelCreate Excel = new ExcelCreate("1");


            foreach (var tempSelectETagRoad in excelJson)
            {
                dynamic 報表 = tempSelectETagRoad.report;
                eTag基本資料 baseInfo = tempSelectETagRoad.baseInfo;
                List<旅行時間> 原始檔 = tempSelectETagRoad.reportBase;




                Excel.sheetCreate(baseInfo.RoadName);
                Excel.設定分時旅行時間報表標題(baseInfo.Date, baseInfo.RoadName);
                foreach (var reportTemp in 報表)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(reportTemp.Hour);
                    textTemp.Add(reportTemp.AvgSecond);
                    textTemp.Add(reportTemp.AvgSpeedHour);
                    textTemp.Add(reportTemp.Max);
                    textTemp.Add(reportTemp.MaxHour);
                    textTemp.Add(reportTemp.Min);
                    textTemp.Add(reportTemp.MinHour);
                    textTemp.Add(reportTemp.CarNum);
                    Excel.旅行時間新增(textTemp);
                }
                Excel.設定旅行時間頁尾();
                Excel.sheetCreate(baseInfo.RoadName + "(原始檔)");
                Excel.旅行時間原始檔標頭();
                foreach (var timeTemp in 原始檔)
                {
                    List<dynamic> textTemp = new List<dynamic>();
                    textTemp.Add(timeTemp.進來時間.ToString("yyyy-MM-dd HH:mm:ss"));
                    textTemp.Add(timeTemp.離開時間.ToString("yyyy-MM-dd HH:mm:ss"));
                    textTemp.Add(timeTemp.PLATEID);
                    textTemp.Add(分鐘計算到小數(timeTemp.秒數, 1));
                    Excel.insertRow(textTemp);
                }
                Excel.設定結束Sheet();
            }
            Excel.excelDownload(context, "分時旅行時間報表");
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

    public string 分鐘計算到小數(dynamic value, int n)
    {
        double temp = value;
        string output = "0.";
        temp = temp / 60;
        for (int i = 0; i < n; i++)
        {
            output = output + "0";
        }

        return temp.ToString(output);
    }

}
public class Excel1
{
    public eTag基本資料 baseInfo;
    public List<eTag分時旅行報表Row> report;
    public List<旅行時間> reportBase;
}

public class eTag基本資料
{
    public string StartID;
    public string EndID;
    public string RoadName;
    public string Date;
}

public class eTag分時旅行時間
{
    public string Hour;
    public int Avg;
    public int Min;
    public int Max;
    public int CarNum;
}

public class 旅行時間
{
    public DateTime 進來時間;
    public DateTime 離開時間;
    public int 秒數;
    public string PLATEID;
}

public class eTag分時旅行報表Row
{
    public string Hour;
    public dynamic AvgSecond;
    public dynamic AvgSpeedHour;
    public dynamic CarNum;
    public dynamic Max;
    public dynamic Min;
    public dynamic MaxHour;
    public dynamic MinHour;
}

public class eTag分時流量報表
{
    public List<eTag分時旅行報表Row> 報表;
}