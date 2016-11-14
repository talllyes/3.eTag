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
        if (type.Equals("多週內日分時旅行時間報表"))
        {
            int reportID = Int32.Parse(context.Request["id"].ToString());
            string te = (from a in DB.Report
                         where a.ReportID == reportID
                         select a.Context).FirstOrDefault();
            Excel1 excelJson = JsonConvert.DeserializeObject<Excel1>(te);


            ExcelCreate Excel = new ExcelCreate("1");
            eTag分時旅行報表 報表 = excelJson.report;
            eTag基本資料 baseInfo = excelJson.baseInfo;
            Excel.sheetCreate("週日");
            Excel.設定週內日分時旅行時間報表標題(baseInfo.date, baseInfo.RoadName, "週日");
            foreach (var reportTemp in 報表.星期日)
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
            Excel.sheetCreate("週一");
            Excel.設定週內日分時旅行時間報表標題(baseInfo.date, baseInfo.RoadName, "週一");
            foreach (var reportTemp in 報表.星期一)
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
            Excel.sheetCreate("週二");
            Excel.設定週內日分時旅行時間報表標題(baseInfo.date, baseInfo.RoadName, "週二");
            foreach (var reportTemp in 報表.星期二)
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
            Excel.sheetCreate("週三");
            Excel.設定週內日分時旅行時間報表標題(baseInfo.date, baseInfo.RoadName, "週三");
            foreach (var reportTemp in 報表.星期三)
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
            Excel.sheetCreate("週四");
            Excel.設定週內日分時旅行時間報表標題(baseInfo.date, baseInfo.RoadName, "週四");
            foreach (var reportTemp in 報表.星期四)
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
            Excel.sheetCreate("週五");
            Excel.設定週內日分時旅行時間報表標題(baseInfo.date, baseInfo.RoadName, "週五");
            foreach (var reportTemp in 報表.星期五)
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
            Excel.sheetCreate("週六");
            Excel.設定週內日分時旅行時間報表標題(baseInfo.date, baseInfo.RoadName, "週六");
            foreach (var reportTemp in 報表.星期六)
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
            Excel.excelDownload(context, "多週內日分時旅行時間報表");
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}


public class Excel1
{
    public eTag基本資料 baseInfo;
    public eTag分時旅行報表 report;
}

public class eTag基本資料
{
    public string ID;
    public string RoadName;
    public string date;
}
public class eTag分時旅行報表
{
    public List<eTag分時旅行報表Row> 星期日;
    public List<eTag分時旅行報表Row> 星期一;
    public List<eTag分時旅行報表Row> 星期二;
    public List<eTag分時旅行報表Row> 星期三;
    public List<eTag分時旅行報表Row> 星期四;
    public List<eTag分時旅行報表Row> 星期五;
    public List<eTag分時旅行報表Row> 星期六;
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