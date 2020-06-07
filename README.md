# 觸控黑白棋				          
組員：馮子軒、趙彥安、蔡易霖

## 預計目標
* 藉由觸控螢幕操控的黑白棋遊戲
  * 單人模式
    * 難度可變
    * 毀棋
  * 雙人模式

## 所需設備
* Altera DE2-115
* LTM觸控螢幕
## 分割模組
* Controller: 控制遊戲進度
* 模式、開始、毀棋、投降等
* 控制其他所有模組
* Receiver: LTM觸控螢幕Input
* Validator: 確認該步合法性
* Updater: 更新棋面
* AI: 單人模式AI
* Target: 目標函數
* Sender: LTM觸控螢幕Output
* 黑白棋AI
* 目標函數：己方棋子數
* 單步最優
* 多步最優(最大最小演算法)
* 目標函數優化
* 靠近邊角的棋子增加權重
* 第二線棋子降低權重
* 最大最小演算法
* 記憶體需求
* 一節點 = 盤面(2bits X 64=128bits) + 目標函數值(8bits暫定)]= 136bits
* 節點數 = (分支數^深度-1)/(分支數-1)
* 五分支五步 = 781 X 136 bits X  MB/8192bits = 13 MB
* DRAM可負荷


# 程式架構
## Controller: 控制遊戲進度
* 模式、開始、投降、毀棋等
* 控制其他所有模組
* ports:
  * input i_clk
  * input i_rst_n
  * input [1:0] mode
    * 0: 單人簡單
    * 1: 單人普通
    * 2: 單人困難
    * 3: 雙人
  * input i_start
  * input i_surrender
  * input i_prestep
## Receiver: LTM觸控螢幕Input
## Updater: 更新盤面
* ports:
  * input i_clk
  * input i_rst_n
  * input i_start
  * input i_color
  * input[2:0] i_row
  * input[2:0] i_col
  * input  [1:0] i_current_board [0:7] [0:7]
  * output [1:0] o_updated_board [0:7] [0:7]
  * output [5:0] o_score [0:1]
    * 盤面上黑白子的數量
  * output [4:0] o_flip
    * 敵方被翻的數量
  * output o_done
## AI: 單人模式AI(蔡易霖)
* ports:
  * input i_clk
  * input i_rst_n
  * input i_start
  * input i_color
  * input  [1:0] i_current_board [0:7] [0:7]
  * output [1:0] o_updated_board [0:7] [0:7]
  * output o_done
    * 計算結束
  * output o_end
    * 該方無法落子
## Sender: LTM觸控螢幕Output
* ports:
  * input i_clk
  * input i_rst_n
  * input i_start
  * input [1:0] i_board [0:7] [0:7]
  * output [2:0] o_row
  * output [2:0] o_column
  * output [] 
  * output o_done
## Initializer: 螢幕
## 遊戲規則定義
  * 白:0
  * 黑:1  先手
  * 無:2
* 電腦沒辦法下→人類再下一次
* 人類沒辦法下→電腦再下一次
* 兩者沒辦法下→結束
* 例子:
* 人類(白)
* 電腦(黑)
* 輪到電腦時，先傳目前盤面
* verilog array : logic[1:0] array_name[0:63]   64*2matrix
* https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=Taiwan&CategoryNo=85&No=990&PartNo=2