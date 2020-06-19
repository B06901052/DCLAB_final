`timescale 1ns/10ps
`define CYCLE  10
`define HCYCLE  5
`define color_file "color.pattern"
`define row_file "row.pattern"
`define column_file "column.pattern"
`define black_file "black_grade.pattern"
`define white_file "white_grade.pattern"
`define pattern_num 60
module AI_tb;

    // port declaration for design-under-test
    logic Clk ;
    logic rst_n,start,COLOR;
    logic [2:0] ROW,COLUMN;
    bit [1:0] i_board [0:7] [0:7];
    bit [1:0] o_board [0:7] [0:7];
    bit [1:0] temp_board [0:7] [0:7];
    bit [1:0] board [0:7] [0:7];
    bit [5:0] grade [0:1];
    logic [4:0] flip;
    logic done,ai_end;
    logic [2:0] max_row,max_col;
    integer  max_grade;
    integer  temp_flip,total_flip;
    integer temp_row,temp_col;
    integer ai_max_grade;
    
    integer count;
    logic [7:0] color[0:`pattern_num-1];
    logic [7:0] column[0:`pattern_num-1];
    logic [7:0] row[0:`pattern_num-1];
    logic [7:0] black[0:`pattern_num-1];
    logic [7:0] white[0:`pattern_num-1];
    logic grade_start,grade_done;
    parameter bit [5:0] weight[0:7][0:7] =
                        '{'{6'd31, 6'd6, 6'd7, 6'd7,6'd7,6'd7,6'd6,6'd31},
                        '{6'd6,6'd0,6'd7,6'd7,6'd7,6'd7,6'd0,6'd6},
                        '{6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7},
                        '{6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7},
                        '{6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7},
                        '{6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7},
                        '{6'd6,6'd0,6'd7,6'd7,6'd7,6'd7,6'd0,6'd6},
                        '{6'd31, 6'd6, 6'd7, 6'd7,6'd7,6'd7,6'd6,6'd31}}; 
    parameter bit signed [2:0] direction[0:1][0:7] =   // from(1,0) clockwise                
                        '{'{2'd0,-2'd1,-2'd1,-2'd1,2'd0,2'd1,2'd1,2'd1},
                        '{2'd1, 2'd1, 2'd0, -2'd1,-2'd1,-2'd1,2'd0,2'd1}}; 
/*
    updater up(
  .i_clk(Clk),
  .i_rst_n(rst_n),
  .i_start(start),
  .i_color(COLOR),
  .i_row(ROW),
  .i_col(COLUMN),
  .i_current_board(i_board),
  .o_updated_board(o_board),
   .o_score (grade),
  .o_flip(flip),
    .o_done(done)
) ;*/
AI ai(
.i_clk(Clk),
 .i_rst_n(rst_n),
.i_start(start),
.i_color(COLOR),
.i_current_board(i_board),
.o_updated_board (o_board),
.o_done(done),
.o_end(ai_end),
.o_max_row(max_row),
.o_max_col(max_col),
.o_max_grade(ai_max_grade)
) ;
/*
grade ai_grade(
.i_clk(Clk),
.i_rst_n(rst_n),
.i_start(grade_start),
.i_board [0:7] [0:7](board),
.o_score [0:1](grade),
.o_done(grade_done)
) ;*/

    initial begin
        $fsdbDumpfile( "AI.fsdb" );
        $fsdbDumpvars(0,AI_tb, "+mda");
    end
    // write your test pattern here
    initial begin
        $readmemh(`color_file,color);// remember to turn pattern from dec to hex
        $readmemh(`column_file,column);
        $readmemh(`row_file,row);
        $readmemh(`black_file,black);
        $readmemh(`white_file,white);
        Clk = 1;
        rst_n=0;
        start=0;
        #(`HCYCLE) rst_n=1;
    end

    always begin #(`HCYCLE) Clk = ~Clk;
    end
    integer i,j,k,m,n;
    integer max_row_random,max_col_random;
    initial begin
        for (i=0;i<8;i=i+1) begin
            for (j=0;j<8;j=j+1) begin
                if(i==3 && j==3) i_board[i][j]=0; //left up
                else if (i==4 && j==3) i_board[i][j]=1; //left down
                else if(i==3 && j==4) i_board[i][j]=1; //right up
                else if(i==4&&j==4) i_board[i][j]=0; // right down
                else i_board[i][j]=2;
            end
        end
        temp_board=i_board;
        count=0;
        #(`HCYCLE)
        max_grade=0;
        while(count<`pattern_num) begin
        o_board=i_board;
        temp_board=i_board;
        #(`CYCLE)
        start=1;
        COLOR=color[count];
        ROW=row[count];
        COLUMN=column[count];
        temp_flip=0;
        #(`CYCLE)
        for(i=0;i<8;i++) begin
                for (j=0;j<8;j++) begin
                    total_flip=0;
                    if(temp_board[i][j]==2) begin
                        
                        for(k=0;k<8;k++) begin
                            //if(count==0&&i==3&&j==2) begin
                                //$display("temp_row:%d temp_col:%d,k:%d",temp_row,temp_col,k);
                            //end
                            temp_flip=0;
                            temp_row=i+direction[0][k];
                            temp_col=j+direction[1][k];
                            
                                //$display("temp_row:%d temp_col:%d,k:%d,temp_board:%d ~COLOR:%d"
                                //,temp_row,temp_col,k,temp_board[temp_row][temp_col],!COLOR);
                            //$display("temp_board[temp_row][temp_col]==(~COLOR):%d",temp_board[temp_row][temp_col]==(!COLOR));
                            //$display("row:%d col:%d",i,j);
                            while(temp_board[temp_row][temp_col]==(!COLOR)) begin
                                temp_flip=temp_flip+1;
                                //if(count==0&&i==3&&j==2) begin
                                //$display("move:%d,enter while, total flip=%d, temp flip:%d,row:%d,col:%d, k:%d",
                                //count+1,total_flip,temp_flip,i,j,k);
                                //$display("temp_row:%d temp_col:%d,k:%d",temp_row,temp_col,k);
                                //$display("direction[0]:%d,direction[1]:%d",direction[0][k],direction[1][k]);
                                //end
                                
                                temp_row=temp_row+direction[0][k];
                                temp_col=temp_col+direction[1][k];
                               
                                //$display("row%d,col%d",i,j);
                                //$display("temp row%d, temp col%d",temp_row,temp_col);
                                //$display("temp_board[temp_row][temp_col]:%d",temp_board[temp_row][temp_col]);
                                if(temp_row<0||temp_row>7||temp_col<0||temp_col>7||temp_board[temp_row][temp_col]==2) begin
                                    temp_flip=0;
                                     //if(count==0&&i==3&&j==2) begin
                                     //$display("enter break move:%d, total flip=%d, temp flip:%d,row:%d,col:%d,k:%d",count+1,total_flip,temp_flip,i,j,k);
                                     //end
                                    break;
                                end
                            end
                            //if(count==0&&i==3&&j==2) begin
                             //   $display("total flip %d,k:%d",total_flip,k);
                            //end
                            total_flip=total_flip+temp_flip;
                            //$display("total flip: %d,row %d,col %d,k %d" ,total_flip,i,j,k);
                        end
                        if(total_flip+weight[i][j]>max_grade&&total_flip>0) begin
                            max_grade=total_flip+weight[i][j];
                            max_row_random=i;
                            max_col_random=j;
                            //$display("max_grade %d,max_row %d,max_col %d,total flip:%d,weight:%d"
                            //,max_grade,max_row_random,max_col_random,total_flip,weight[i][j]);
                        end
                    end
                    //$display("max grade %d,row %d,col %d", max_grade,i,j);
                end
            end
            //$display("max_grade %d,max_row %d,max_col %d",max_grade,max_row_random,max_col_random);
        #(`CYCLE)
        start=0;
        ROW=0;
        COLUMN=0;
       //COLOR=0;
        for (i=0;i<8;i=i+1) begin
            for (j=0;j<8;j=j+1) begin
                i_board[i][j]=0;
            end
        end
        
        @(done==1) begin
 /*           if(grade[0]==white[count]&&grade[1]==black[count]) begin
                $display("step %d pass color %d, row = %d column %d, black = %d white %d",count+1, color[count],row[count]
            ,column[count],black[count],white[count]);
            end
            else begin
                $display("step %d fail color %d, row = %d column %d, black = %d, correct black=%d white %d,correct white=%d"
                ,count+1, color[count],row[count],column[count],grade[1],black[count],grade[0],white[count]);
            end
            */
            //$display("move %d",count+1);

            if(max_row==row[count]&&max_col==column[count]) begin
                $display("move %d pass row %d column %d",count+1,max_row,max_col);
            end
            else begin
                $display("move %d fail row %d column %d correct row %d correct column %d",
                count+1,max_row,max_col,row[count],column[count]);
            end
            if(ai_max_grade==max_grade) begin
                $display("move %d grade pass grade %d",count+1,max_grade);
            end
            else begin
                $display("move %d grade fail ai:%d tb:%d",count+1,ai_max_grade,max_grade);
            end
            start=0;
            count=count+1;
            i_board=o_board;


        end
        end
        // now test o_end
        COLOR=1;
        #(`CYCLE)
        start=1;
        COLOR=1;
        #(`CYCLE)
        start=0;
        @(done==1) begin
            if(ai_end==1) begin
                $display("pass end test");
            end
            else begin
                $display("fail end test");
            end
        end

    $finish;
    end
    initial begin
		#(3000_00*Clk)
		$display("Too slow, abort.");
		$finish;
	end

endmodule
