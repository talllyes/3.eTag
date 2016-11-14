using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using NPOI;
using NPOI.HSSF.UserModel;
using NPOI.XSSF.UserModel;
using NPOI.SS.UserModel;
using System.IO;
using NPOI.SS.Util;

/// <summary>
/// ExcelCreate 的摘要描述
/// </summary>
public class ExcelCreate
{
    XSSFWorkbook workbook;
    List<dynamic> titleTemp;
    List<dynamic> widthTemp;
    XSSFCellStyle oStyle;
    XSSFCellStyle oStyle2;
    XSSFCellStyle oStyle3;
    List<XSSFSheet> sheet = new List<XSSFSheet>();
    int nowRow = 0;
    int sheetNum = 0;
    public ExcelCreate()
    {
        workbook = new XSSFWorkbook();
        XSSFSheet sheetTemp = (XSSFSheet)workbook.CreateSheet("第 " + (sheetNum + 1) + " 頁");
        sheet.Add(sheetTemp);
        SetSheet(sheet[sheetNum]);
    }
    public ExcelCreate(string str)
    {
        workbook = new XSSFWorkbook();
        oStyle = CsSet(12, true);
        oStyle2 = CsSet2(12, true);
        oStyle3 = CsSet3(12, true);

    }
    public void sheetCreate(string str)
    {
        XSSFSheet sheetTemp = (XSSFSheet)workbook.CreateSheet(str);
        sheet.Add(sheetTemp);
        SetSheet(sheet[sheetNum]);
    }

    public void setWidth(List<dynamic> width)
    {
        widthTemp = width;
        int colNum = 0;
        foreach (var temp in width)
        {
            sheet[sheetNum].SetColumnWidth(colNum, temp * 256);
            colNum = colNum + 1;
        }
    }

    public void setTitle(List<dynamic> data)
    {
        titleTemp = data;
        IRow rowTitle = sheet[sheetNum].CreateRow(nowRow);
        int colNum = 0;
        foreach (var temp in data)
        {
            rowTitle.CreateCell(colNum);
            rowTitle.GetCell(colNum).SetCellValue(temp);
            colNum = colNum + 1;
        }
        nowRow = nowRow + 1;
    }

    public void 分時流量新增(List<dynamic> data)
    {
        IRow thisRow = sheet[sheetNum].CreateRow(nowRow);
        int colNum = 0;
        foreach (var temp in data)
        {
            thisRow.CreateCell(colNum);
            thisRow.GetCell(colNum).SetCellValue(temp);
            if (colNum == 0)
            {
                thisRow.GetCell(0).CellStyle = oStyle;
            }
            else
            {
                thisRow.GetCell(colNum).CellStyle = oStyle2;
            }
            colNum = colNum + 1;
        }
        thisRow.HeightInPoints = 20;
        nowRow = nowRow + 1;
    }

    public void 旅行時間原始檔標頭()
    {
        sheet[sheetNum].SetColumnWidth(0, 20 * 256);
        sheet[sheetNum].SetColumnWidth(1, 20 * 256);
        sheet[sheetNum].SetColumnWidth(2, 35 * 256);
        sheet[sheetNum].SetColumnWidth(3, 20 * 256);
        IRow rowTitle = sheet[sheetNum].CreateRow(nowRow);
        rowTitle.CreateCell(0).SetCellValue("進來時間");
        rowTitle.CreateCell(1).SetCellValue("離開時間");
        rowTitle.CreateCell(2).SetCellValue("ETagID");
        rowTitle.CreateCell(3).SetCellValue("分");
        nowRow = nowRow + 1;
    }


    public void insertRow(List<dynamic> data)
    {
        IRow thisRow = sheet[sheetNum].CreateRow(nowRow);
        int colNum = 0;
        foreach (var temp in data)
        {
            thisRow.CreateCell(colNum);
            thisRow.GetCell(colNum).SetCellValue(temp);
            colNum = colNum + 1;
        }
        nowRow = nowRow + 1;
        if (nowRow > 50000)
        {
            sheetNum = sheetNum + 1;
            XSSFSheet sheetTemp = (XSSFSheet)workbook.CreateSheet("第 " + (sheetNum + 1) + " 頁");
            sheet.Add(sheetTemp);
            nowRow = 0;
            SetSheet(sheet[sheetNum]);
            if (titleTemp != null)
            {
                setTitle(titleTemp);
            }
            if (widthTemp != null)
            {
                setWidth(widthTemp);
            }
        }
    }

    public void excelOutput(HttpRequest Request, string name)
    {
        string fileLocation = Request.PhysicalApplicationPath;
        FileStream file = new FileStream(fileLocation + @"Excel\" + name + @".xlsx", FileMode.Create);//產生檔案
        workbook.Write(file);
        file.Close();
    }

    public void excelDownload(HttpContext context, string name)
    {
        string fileLocation = context.Request.PhysicalApplicationPath;
        MemoryStream MS = new MemoryStream();   //==需要 System.IO命名空間
        workbook.Write(MS);
        //== Excel檔名，請寫在最後面 filename的地方
        context.Response.AddHeader("Content-Disposition", "attachment; filename=" + name + DateTime.Now.ToString("yyyyMMddhhmm") + ".xlsx");
        context.Response.BinaryWrite(MS.ToArray());
        //== 釋放資源
        workbook = null;
        MS.Close();
        MS.Dispose();
        context.Response.Flush();
        context.Response.End();
    }


    public void SetSheet(XSSFSheet s)
    {
        s.PrintSetup.FitWidth = 1;
        s.PrintSetup.FitHeight = 1;
    }
    public XSSFCellStyle CsSet(short size, bool x)
    {
        XSSFFont font = (XSSFFont)workbook.CreateFont();
        font.FontName = "微軟正黑體";
        font.FontHeightInPoints = size;
        XSSFCellStyle cs = (XSSFCellStyle)workbook.CreateCellStyle();
        cs.SetFont(font);
        cs.WrapText = true;
        cs.VerticalAlignment = VerticalAlignment.Center;
        cs.Alignment = HorizontalAlignment.Center;

        if (x)
        {
            cs.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.WrapText = true;
        }
        return cs;
    }
    public XSSFCellStyle CsSet2(short size, bool x)
    {
        XSSFFont font = (XSSFFont)workbook.CreateFont();
        font.FontName = "微軟正黑體";
        font.FontHeightInPoints = size;
        XSSFCellStyle cs = (XSSFCellStyle)workbook.CreateCellStyle();
        cs.SetFont(font);
        cs.WrapText = true;
        cs.VerticalAlignment = VerticalAlignment.Center;
        cs.Alignment = HorizontalAlignment.Right;
        if (x)
        {
            cs.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.WrapText = true;
        }
        return cs;
    }
    public XSSFCellStyle CsSet3(short size, bool x)
    {
        XSSFFont font = (XSSFFont)workbook.CreateFont();
        font.FontName = "微軟正黑體";
        font.FontHeightInPoints = size;
        XSSFCellStyle cs = (XSSFCellStyle)workbook.CreateCellStyle();
        cs.SetFont(font);
        cs.WrapText = true;
        cs.VerticalAlignment = VerticalAlignment.Center;
        cs.Alignment = HorizontalAlignment.Left;
        if (x)
        {
            cs.BorderBottom = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderLeft = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderRight = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.BorderTop = NPOI.SS.UserModel.BorderStyle.Thin;
            cs.WrapText = true;
        }
        return cs;
    }

    public void 新增儲存格(IRow rowTitle, int n)
    {
        for (int i = 0; i < n; i++)
        {
            rowTitle.CreateCell(i);
        }
    }



    public void 設定分時流量報表標題(string date, string name)
    {
        sheet[sheetNum].SetColumnWidth(0, 20 * 256);
        sheet[sheetNum].SetColumnWidth(1, 15 * 256);
        sheet[sheetNum].SetColumnWidth(2, 15 * 256);
        sheet[sheetNum].SetColumnWidth(3, 15 * 256);
        sheet[sheetNum].SetColumnWidth(4, 15 * 256);
        sheet[sheetNum].SetColumnWidth(5, 15 * 256);
        IRow rowTitle = sheet[sheetNum].CreateRow(nowRow);
        rowTitle.CreateCell(0).SetCellValue("單日eTag - 分時流量報表");
        rowTitle.CreateCell(1);
        rowTitle.CreateCell(2);
        rowTitle.CreateCell(3);
        rowTitle.CreateCell(4);
        rowTitle.CreateCell(5);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(0, 0, 0, 5));
        nowRow = nowRow + 1;
        IRow rowTitle2 = sheet[sheetNum].CreateRow(nowRow);
        rowTitle2.CreateCell(0).SetCellValue("日期");
        rowTitle2.CreateCell(1).SetCellValue(date);
        rowTitle2.CreateCell(2);
        rowTitle2.CreateCell(3);
        rowTitle2.CreateCell(4);
        rowTitle2.CreateCell(5);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(1, 1, 1, 5));
        nowRow = nowRow + 1;
        IRow rowTitle3 = sheet[sheetNum].CreateRow(nowRow);
        rowTitle3.CreateCell(0).SetCellValue("設備編號、名稱");
        rowTitle3.CreateCell(1).SetCellValue(name);
        rowTitle3.CreateCell(2);
        rowTitle3.CreateCell(3);
        rowTitle3.CreateCell(4);
        rowTitle3.CreateCell(5);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(2, 2, 1, 5));
        nowRow = nowRow + 1;
        IRow rowTitle4 = sheet[sheetNum].CreateRow(nowRow);
        rowTitle4.CreateCell(0).SetCellValue("時間");
        rowTitle4.CreateCell(1).SetCellValue("總流量");
        rowTitle4.CreateCell(2).SetCellValue("聯結車流量");
        rowTitle4.CreateCell(3).SetCellValue("大型車流量");
        rowTitle4.CreateCell(4).SetCellValue("小型車流量");
        rowTitle4.CreateCell(5).SetCellValue("其他車流量");
        nowRow = nowRow + 1;
        for (int x = 0; x < 6; x++)
        {
            rowTitle.GetCell(x).CellStyle = oStyle;
            rowTitle2.GetCell(x).CellStyle = oStyle;
            rowTitle3.GetCell(x).CellStyle = oStyle;
            rowTitle4.GetCell(x).CellStyle = oStyle;
        }
        rowTitle.HeightInPoints = 20;
        rowTitle2.HeightInPoints = 20;
        rowTitle3.HeightInPoints = 20;
        rowTitle4.HeightInPoints = 20;
    }

    public void setFooter()
    {
        IRow rowTitle = sheet[sheetNum].CreateRow(nowRow);
        IRow rowTitle2 = sheet[sheetNum].CreateRow(nowRow + 1);
        IRow rowTitle3 = sheet[sheetNum].CreateRow(nowRow + 2);
        rowTitle.CreateCell(0).SetCellValue("附註");
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(nowRow, nowRow + 2, 0, 0));
        rowTitle.CreateCell(1).SetCellValue("1");
        rowTitle.CreateCell(2).SetCellValue("晨峰：早上7-9點數值之平均值");
        rowTitle.CreateCell(3);
        rowTitle.CreateCell(4);
        rowTitle.CreateCell(5);

        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(nowRow, nowRow, 2, 5));
        nowRow = nowRow + 1;
        rowTitle2.CreateCell(0);
        rowTitle2.CreateCell(1).SetCellValue("2");
        rowTitle2.CreateCell(2).SetCellValue("昏峰：早上17-19點數值之平均值");
        rowTitle2.CreateCell(3);
        rowTitle2.CreateCell(4);
        rowTitle2.CreateCell(5);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(nowRow, nowRow, 2, 5));
        nowRow = nowRow + 1;
        rowTitle3.CreateCell(0);
        rowTitle3.CreateCell(1).SetCellValue("3");
        rowTitle3.CreateCell(2).SetCellValue("離峰：早上9-17點數值之平均值");
        rowTitle3.CreateCell(3);
        rowTitle3.CreateCell(4);
        rowTitle3.CreateCell(5);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(nowRow, nowRow, 2, 5));

        for (int x = 0; x < 6; x++)
        {
            if (x == 2)
            {
                rowTitle.GetCell(x).CellStyle = oStyle3;
                rowTitle2.GetCell(x).CellStyle = oStyle3;
                rowTitle3.GetCell(x).CellStyle = oStyle3;
            }
            else
            {
                rowTitle.GetCell(x).CellStyle = oStyle;
                rowTitle2.GetCell(x).CellStyle = oStyle;
                rowTitle3.GetCell(x).CellStyle = oStyle;
            }

        }
        rowTitle.HeightInPoints = 20;
        rowTitle2.HeightInPoints = 20;
        rowTitle3.HeightInPoints = 20;
        nowRow = nowRow + 1;
        sheetNum = sheetNum + 1;
        nowRow = 0;
    }



    public void 換sheet()
    {
        nowRow = nowRow + 1;
        sheetNum = sheetNum + 1;
        nowRow = 0;
    }
    public void 設定分時旅行時間報表標題(string date, string name)
    {
        sheet[sheetNum].SetColumnWidth(0, 20 * 256);
        sheet[sheetNum].SetColumnWidth(1, 11 * 256);
        sheet[sheetNum].SetColumnWidth(2, 11 * 256);
        sheet[sheetNum].SetColumnWidth(3, 11 * 256);
        sheet[sheetNum].SetColumnWidth(4, 11 * 256);
        sheet[sheetNum].SetColumnWidth(5, 11 * 256);
        sheet[sheetNum].SetColumnWidth(6, 11 * 256);
        sheet[sheetNum].SetColumnWidth(7, 11 * 256);

        IRow rowTitle = sheet[sheetNum].CreateRow(nowRow);
        新增儲存格(rowTitle, 8);
        rowTitle.GetCell(0).SetCellValue("單日eTag - 分時旅行時間報表");
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(0, 0, 0, 7));
        nowRow = nowRow + 1;

        IRow rowTitle2 = sheet[sheetNum].CreateRow(nowRow);
        新增儲存格(rowTitle2, 8);
        rowTitle2.GetCell(0).SetCellValue("日期");
        rowTitle2.GetCell(1).SetCellValue(date);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(1, 1, 1, 7));
        nowRow = nowRow + 1;

        IRow rowTitle3 = sheet[sheetNum].CreateRow(nowRow);
        新增儲存格(rowTitle3, 8);
        rowTitle3.GetCell(0).SetCellValue("設備編號、名稱");
        rowTitle3.GetCell(1).SetCellValue(name);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(2, 2, 1, 7));
        nowRow = nowRow + 1;

        IRow rowTitle4 = sheet[sheetNum].CreateRow(nowRow);
        rowTitle4.CreateCell(0).SetCellValue("時間");
        rowTitle4.CreateCell(1).SetCellValue("平均(分)");
        rowTitle4.CreateCell(2).SetCellValue("平均速率(公里 / 小時)");
        rowTitle4.CreateCell(3).SetCellValue("最大(分)");
        rowTitle4.CreateCell(4).SetCellValue("最大速率(公里 / 小時)");
        rowTitle4.CreateCell(5).SetCellValue("最小(分)");
        rowTitle4.CreateCell(6).SetCellValue("最小速率(公里 / 小時)");
        rowTitle4.CreateCell(7).SetCellValue("統計車輛數");
        nowRow = nowRow + 1;

        for (int x = 0; x < 8; x++)
        {
            rowTitle.GetCell(x).CellStyle = oStyle;
            rowTitle2.GetCell(x).CellStyle = oStyle;
            rowTitle3.GetCell(x).CellStyle = oStyle;
            rowTitle4.GetCell(x).CellStyle = oStyle;
        }

        rowTitle.HeightInPoints = 20;
        rowTitle2.HeightInPoints = 20;
        rowTitle3.HeightInPoints = 20;
        rowTitle4.HeightInPoints = 50;
    }

    public void 旅行時間新增(List<dynamic> data)
    {
        IRow thisRow = sheet[sheetNum].CreateRow(nowRow);
        int colNum = 0;
        foreach (var temp in data)
        {

            thisRow.CreateCell(colNum);
            if (colNum == 0)
            {
                thisRow.GetCell(colNum).SetCellValue(temp);
                thisRow.GetCell(0).CellStyle = oStyle;
            }
            else
            {
                string a = temp + "";
                thisRow.GetCell(colNum).SetCellValue(Double.Parse(a));
                thisRow.GetCell(colNum).CellStyle = oStyle2;
            }
            colNum = colNum + 1;
        }
        thisRow.HeightInPoints = 20;
        nowRow = nowRow + 1;
    }

    public void 設定旅行時間頁尾()
    {
        IRow rowTitle = sheet[sheetNum].CreateRow(nowRow);
        IRow rowTitle2 = sheet[sheetNum].CreateRow(nowRow + 1);
        IRow rowTitle3 = sheet[sheetNum].CreateRow(nowRow + 2);

        新增儲存格(rowTitle, 8);
        rowTitle.GetCell(0).SetCellValue("附註");
        rowTitle.GetCell(1).SetCellValue("1");
        rowTitle.GetCell(2).SetCellValue("晨峰：早上7-9點數值之平均值");
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(nowRow, nowRow + 2, 0, 0));
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(nowRow, nowRow, 2, 7));
        nowRow = nowRow + 1;

        新增儲存格(rowTitle2, 8);
        rowTitle2.GetCell(1).SetCellValue("2");
        rowTitle2.GetCell(2).SetCellValue("昏峰：早上17-19點數值之平均值");
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(nowRow, nowRow, 2, 7));
        nowRow = nowRow + 1;

        新增儲存格(rowTitle3, 8);
        rowTitle3.GetCell(1).SetCellValue("3");
        rowTitle3.GetCell(2).SetCellValue("離峰：早上9-17點數值之平均值");
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(nowRow, nowRow, 2, 7));

        for (int x = 0; x < 8; x++)
        {
            if (x == 2)
            {
                rowTitle.GetCell(x).CellStyle = oStyle3;
                rowTitle2.GetCell(x).CellStyle = oStyle3;
                rowTitle3.GetCell(x).CellStyle = oStyle3;
            }
            else
            {
                rowTitle.GetCell(x).CellStyle = oStyle;
                rowTitle2.GetCell(x).CellStyle = oStyle;
                rowTitle3.GetCell(x).CellStyle = oStyle;
            }

        }
        rowTitle.HeightInPoints = 20;
        rowTitle2.HeightInPoints = 20;
        rowTitle3.HeightInPoints = 20;
        nowRow = nowRow + 1;
        sheetNum = sheetNum + 1;
        nowRow = 0;
    }
    public void 設定結束Sheet()
    {
        nowRow = nowRow + 1;
        sheetNum = sheetNum + 1;
        nowRow = 0;
    }
    public void 設定週日內分時流量報表標題(string date, string name, string 星期)
    {


        sheet[sheetNum].SetColumnWidth(0, 20 * 256);
        sheet[sheetNum].SetColumnWidth(1, 15 * 256);
        sheet[sheetNum].SetColumnWidth(2, 15 * 256);
        sheet[sheetNum].SetColumnWidth(3, 15 * 256);
        sheet[sheetNum].SetColumnWidth(4, 15 * 256);
        sheet[sheetNum].SetColumnWidth(5, 15 * 256);
        IRow rowTitle = sheet[sheetNum].CreateRow(nowRow);
        rowTitle.CreateCell(0).SetCellValue("多週內日 - 單eTag - 分時流量報表");
        rowTitle.CreateCell(1);
        rowTitle.CreateCell(2);
        rowTitle.CreateCell(3);
        rowTitle.CreateCell(4);
        rowTitle.CreateCell(5);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(0, 0, 0, 5));
        nowRow = nowRow + 1;
        IRow rowTitle2 = sheet[sheetNum].CreateRow(nowRow);
        rowTitle2.CreateCell(0).SetCellValue("時段");
        rowTitle2.CreateCell(1).SetCellValue(date);
        rowTitle2.CreateCell(2);
        rowTitle2.CreateCell(3);
        rowTitle2.CreateCell(4);
        rowTitle2.CreateCell(5);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(1, 1, 1, 5));
        nowRow = nowRow + 1;
        IRow rowTitle3 = sheet[sheetNum].CreateRow(nowRow);
        rowTitle3.CreateCell(0).SetCellValue("設備編號、名稱");
        rowTitle3.CreateCell(1).SetCellValue(name);
        rowTitle3.CreateCell(2);
        rowTitle3.CreateCell(3);
        rowTitle3.CreateCell(4);
        rowTitle3.CreateCell(5);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(2, 2, 1, 5));
        nowRow = nowRow + 1;
        IRow rowTitle5 = sheet[sheetNum].CreateRow(nowRow);
        rowTitle5.CreateCell(0).SetCellValue("週內日");
        rowTitle5.CreateCell(1).SetCellValue(星期);
        rowTitle5.CreateCell(2);
        rowTitle5.CreateCell(3);
        rowTitle5.CreateCell(4);
        rowTitle5.CreateCell(5);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(3, 3, 1, 5));
        nowRow = nowRow + 1;
        IRow rowTitle4 = sheet[sheetNum].CreateRow(nowRow);
        rowTitle4.CreateCell(0).SetCellValue("時間");
        rowTitle4.CreateCell(1).SetCellValue("總流量");
        rowTitle4.CreateCell(2).SetCellValue("聯結車流量");
        rowTitle4.CreateCell(3).SetCellValue("大型車流量");
        rowTitle4.CreateCell(4).SetCellValue("小型車流量");
        rowTitle4.CreateCell(5).SetCellValue("其他車流量");
        nowRow = nowRow + 1;
        for (int x = 0; x < 6; x++)
        {
            rowTitle.GetCell(x).CellStyle = oStyle;
            rowTitle2.GetCell(x).CellStyle = oStyle;
            rowTitle3.GetCell(x).CellStyle = oStyle;
            rowTitle4.GetCell(x).CellStyle = oStyle;
            rowTitle5.GetCell(x).CellStyle = oStyle;
        }
        rowTitle.HeightInPoints = 20;
        rowTitle2.HeightInPoints = 20;
        rowTitle3.HeightInPoints = 20;
        rowTitle4.HeightInPoints = 20;
        rowTitle5.HeightInPoints = 20;
    }

    public void 設定週內日分時旅行時間報表標題(string date, string name, string 星期)
    {
        sheet[sheetNum].SetColumnWidth(0, 20 * 256);
        sheet[sheetNum].SetColumnWidth(1, 11 * 256);
        sheet[sheetNum].SetColumnWidth(2, 11 * 256);
        sheet[sheetNum].SetColumnWidth(3, 11 * 256);
        sheet[sheetNum].SetColumnWidth(4, 11 * 256);
        sheet[sheetNum].SetColumnWidth(5, 11 * 256);
        sheet[sheetNum].SetColumnWidth(6, 11 * 256);
        sheet[sheetNum].SetColumnWidth(7, 11 * 256);

        IRow rowTitle = sheet[sheetNum].CreateRow(nowRow);
        新增儲存格(rowTitle, 8);
        rowTitle.GetCell(0).SetCellValue("多週內日 - 單路段分時旅行時間報表");
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(0, 0, 0, 7));
        nowRow = nowRow + 1;

        IRow rowTitle2 = sheet[sheetNum].CreateRow(nowRow);
        新增儲存格(rowTitle2, 8);
        rowTitle2.GetCell(0).SetCellValue("日期");
        rowTitle2.GetCell(1).SetCellValue(date);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(1, 1, 1, 7));
        nowRow = nowRow + 1;

        IRow rowTitle3 = sheet[sheetNum].CreateRow(nowRow);
        新增儲存格(rowTitle3, 8);
        rowTitle3.GetCell(0).SetCellValue("設備編號、名稱");
        rowTitle3.GetCell(1).SetCellValue(name);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(2, 2, 1, 7));
        nowRow = nowRow + 1;

        IRow rowTitle5 = sheet[sheetNum].CreateRow(nowRow);
        rowTitle5.CreateCell(0).SetCellValue("週內日");
        rowTitle5.CreateCell(1).SetCellValue(星期);
        rowTitle5.CreateCell(2);
        rowTitle5.CreateCell(3);
        rowTitle5.CreateCell(4);
        rowTitle5.CreateCell(5);
        rowTitle5.CreateCell(6);
        rowTitle5.CreateCell(7);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(3, 3, 1, 7));
        nowRow = nowRow + 1;

        IRow rowTitle4 = sheet[sheetNum].CreateRow(nowRow);
        rowTitle4.CreateCell(0).SetCellValue("時間");
        rowTitle4.CreateCell(1).SetCellValue("平均(分)");
        rowTitle4.CreateCell(2).SetCellValue("平均速率(公里 / 小時)");
        rowTitle4.CreateCell(3).SetCellValue("最大(分)");
        rowTitle4.CreateCell(4).SetCellValue("最大速率(公里 / 小時)");
        rowTitle4.CreateCell(5).SetCellValue("最小(分)");
        rowTitle4.CreateCell(6).SetCellValue("最小速率(公里 / 小時)");
        rowTitle4.CreateCell(7).SetCellValue("統計車輛數");
        nowRow = nowRow + 1;

        for (int x = 0; x < 8; x++)
        {
            rowTitle.GetCell(x).CellStyle = oStyle;
            rowTitle2.GetCell(x).CellStyle = oStyle;
            rowTitle3.GetCell(x).CellStyle = oStyle;
            rowTitle5.GetCell(x).CellStyle = oStyle;
            rowTitle4.GetCell(x).CellStyle = oStyle;
        }

        rowTitle.HeightInPoints = 20;
        rowTitle2.HeightInPoints = 20;
        rowTitle3.HeightInPoints = 20;
        rowTitle5.HeightInPoints = 20;
        rowTitle4.HeightInPoints = 50;
    }

    public void 設定歷史分時流量報表標題(string date, string 星期)
    {
        sheet[sheetNum].SetColumnWidth(0, 20 * 256);
        sheet[sheetNum].SetColumnWidth(1, 11 * 256);
        sheet[sheetNum].SetColumnWidth(2, 11 * 256);
        sheet[sheetNum].SetColumnWidth(3, 11 * 256);
        sheet[sheetNum].SetColumnWidth(4, 11 * 256);
        sheet[sheetNum].SetColumnWidth(5, 11 * 256);
        sheet[sheetNum].SetColumnWidth(6, 11 * 256);
        sheet[sheetNum].SetColumnWidth(7, 11 * 256);
        sheet[sheetNum].SetColumnWidth(8, 11 * 256);
        sheet[sheetNum].SetColumnWidth(9, 11 * 256);
        sheet[sheetNum].SetColumnWidth(10, 11 * 256);
        sheet[sheetNum].SetColumnWidth(11, 11 * 256);
        sheet[sheetNum].SetColumnWidth(12, 11 * 256);
        IRow rowTitle = sheet[sheetNum].CreateRow(nowRow);
        新增儲存格(rowTitle, 14);
        rowTitle.GetCell(0).SetCellValue("哈瑪星及西子灣進出累計車流輛");
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(0, 0, 0, 12));
        nowRow = nowRow + 1;

        IRow rowTitle2 = sheet[sheetNum].CreateRow(nowRow);
        新增儲存格(rowTitle2, 14);
        rowTitle2.GetCell(0).SetCellValue("日期");
        rowTitle2.GetCell(1).SetCellValue(date);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(1, 1, 1, 12));
        nowRow = nowRow + 1;

        IRow rowTitle5 = sheet[sheetNum].CreateRow(nowRow);
        新增儲存格(rowTitle5, 14);
        rowTitle5.GetCell(0).SetCellValue("週內日");
        rowTitle5.GetCell(1).SetCellValue(星期);
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(2, 2, 1, 12));
        nowRow = nowRow + 1;

        IRow rowTitle3 = sheet[sheetNum].CreateRow(nowRow);
        新增儲存格(rowTitle3, 14);
        rowTitle3.GetCell(0).SetCellValue("設備編號、名稱");
        rowTitle3.GetCell(1).SetCellValue("哈瑪星地區");
        rowTitle3.GetCell(7).SetCellValue("西子灣地區");
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(3, 3, 1, 6));
        sheet[sheetNum].AddMergedRegion(new CellRangeAddress(3, 3, 7, 12));
        nowRow = nowRow + 1;



        IRow rowTitle4 = sheet[sheetNum].CreateRow(nowRow);
        rowTitle4.CreateCell(0).SetCellValue("時間");
        rowTitle4.CreateCell(1).SetCellValue("進入");
        rowTitle4.CreateCell(2).SetCellValue("累積進入");
        rowTitle4.CreateCell(3).SetCellValue("離開");
        rowTitle4.CreateCell(4).SetCellValue("累積離開");
        rowTitle4.CreateCell(5).SetCellValue("滯留");
        rowTitle4.CreateCell(6).SetCellValue("累積滯留");
        rowTitle4.CreateCell(7).SetCellValue("進入");
        rowTitle4.CreateCell(8).SetCellValue("累積進入");
        rowTitle4.CreateCell(9).SetCellValue("離開");
        rowTitle4.CreateCell(10).SetCellValue("累積離開");
        rowTitle4.CreateCell(11).SetCellValue("滯留");
        rowTitle4.CreateCell(12).SetCellValue("累積滯留");
        nowRow = nowRow + 1;

        for (int x = 0; x < 13; x++)
        {
            rowTitle.GetCell(x).CellStyle = oStyle;
            rowTitle2.GetCell(x).CellStyle = oStyle;
            rowTitle3.GetCell(x).CellStyle = oStyle;
            rowTitle5.GetCell(x).CellStyle = oStyle;
            rowTitle4.GetCell(x).CellStyle = oStyle;
        }

        rowTitle.HeightInPoints = 20;
        rowTitle2.HeightInPoints = 20;
        rowTitle3.HeightInPoints = 20;
        rowTitle5.HeightInPoints = 20;
        rowTitle4.HeightInPoints = 50;
    }
}