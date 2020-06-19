`timescale 1ns/10ps
module AI(
  input   i_clk,
  input   i_rst_n,
  input   i_start,
  input i_color,
  input  [1:0] i_current_board [0:7] [0:7],
  output [1:0] o_updated_board [0:7] [0:7],
  output o_done,
  output o_end,
  output [2:0] o_max_row,
  output [2:0] o_max_col
) ;
// this is the module to calculate the number black and white stones on the board
localparam IDLE = 0;
localparam TRAVERSE = 1;
localparam CHECK_TRAVERSE = 2;
localparam UPDATE=3;
localparam CHECK_UPDATE=4;
localparam DONE = 5;
//logic [5:0] black_grade_w, black_grade_r, white_grade_w, white_grade_r;
logic [2:0] row_w,row_r,col_w,col_r;
logic [2:0] state_w, state_r;
logic [6:0] max_score_r, max_score_w;
logic [2:0] max_row_r,max_row_w,max_col_w,max_col_r; 
logic done;// when all fone
logic [1:0] board_r [0:7][0:7];
logic [1:0] board_w [0:7][0:7];
logic [1:0] up_board [0:7][0:7];
logic color_r,color_w;
logic up_start,up_done;
logic [4:0] up_flip;
logic [5:0] current_weight;
logic [5:0] counter_w, counter_r;
parameter bit [5:0] weight[0:7][0:7] =
                        '{'{6'd31, 6'd6, 6'd7, 6'd7,6'd7,6'd7,6'd6,6'd31},
                        '{6'd6,6'd0,6'd7,6'd7,6'd7,6'd7,6'd0,6'd6},
                        '{6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7},
                        '{6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7},
                        '{6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7},
                        '{6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7,6'd7},
                        '{6'd6,6'd0,6'd7,6'd7,6'd7,6'd7,6'd0,6'd6},
                        '{6'd31, 6'd6, 6'd7, 6'd7,6'd7,6'd7,6'd6,6'd31}}; 
logic cannot_move;
assign o_end=cannot_move;
assign o_done=done;
assign current_weight=weight[row_r][col_r];
assign o_max_row=max_row_r;
assign o_max_col=max_col_r;
updater upAI(
  .i_clk(i_clk),
  .i_rst_n(i_rst_n),
  .i_start(up_start),
  .i_color(color_r),
  .i_row(row_r),
  .i_col(col_r),
  .i_current_board(board_r),
    .o_updated_board(up_board),
  .o_flip(up_flip),
  .o_done(up_done)
) ;
integer i,j,k,m;
always_comb begin
    row_w=row_r;
    col_w=col_r;
    state_w=state_r;
    max_score_w=max_score_r;
    max_row_w=max_row_r;
    max_col_w=max_col_r;
    done=0;
    color_w=color_r;
    up_start=0;
    cannot_move=0;
    for (i=0;i<8;i=i+1) begin
        for (j=0;j<8;j=j+1) begin
            board_w[i][j]=board_r[i][j];
        end
    end
    for (i=0;i<8;i=i+1) begin
        for (j=0;j<8;j=j+1) begin
            o_updated_board[i][j]=board_r[i][j];
        end
    end
    case(state_r)
        IDLE: begin
            done=0;
            up_start=0;
            if(i_start) begin
                row_w=0;
                col_w=0;
                state_w=TRAVERSE;
                max_score_w=0;
                max_row_w=0;
                max_col_w=0;
                color_w=i_color;
                for (i=0;i<8;i=i+1) begin
                    for (j=0;j<8;j=j+1) begin
                        board_w[i][j]=i_current_board[i][j];
                    end
                end
            end
            else begin
                row_w=0;
                col_w=0;
                state_w=IDLE;
                max_score_w=0;
                max_row_w=0;
                max_col_w=0;
                color_w=0;
                for (i=0;i<8;i=i+1) begin
                    for (j=0;j<8;j=j+1) begin
                        board_w[i][j]=0;
                    end
                end
            end
        end
        TRAVERSE: begin
            done=0;
            max_score_w=max_score_r;
            max_row_w=max_row_r;
            max_col_w=max_col_r;
            color_w=color_r;
            for (i=0;i<8;i=i+1) begin
                for (j=0;j<8;j=j+1) begin
                        board_w[i][j]=board_r[i][j];
                end
            end
            if(board_r[row_r][col_r]==2) begin
                up_start=1;
                row_w=row_r;
                col_w=col_r;
                state_w=CHECK_TRAVERSE;
            end
            else begin
                up_start=0;                
                if(row_r==7&&col_r==7) begin
                    state_w=UPDATE;
 
                    row_w=max_row_r;
                    col_w=max_col_r;// need to update the board with max row,col
                    
                end
                else begin
                    state_w=TRAVERSE;
                    if(row_r==7) begin // need to change to next col
                        row_w=0;
                        col_w=col_r+1;
                    end
                    else begin
                        row_w=row_r+1;
                        col_w=col_r;
                    end
                end
            end

        end
        CHECK_TRAVERSE: begin //wait until updater is done
            done=0;
            up_start=0;
            color_w=color_r;
            for (i=0;i<8;i=i+1) begin
                for (j=0;j<8;j=j+1) begin
                        board_w[i][j]=board_r[i][j];
                end
            end
            if(up_done) begin
                // about row,column and state
                if(row_r==7&&col_r==7) begin
                    state_w=UPDATE;
                    if (up_flip>0 && current_weight+up_flip>max_score_r) begin
                        row_w=7;
                        col_w=7;
                    end
                    else begin
                        row_w=max_row_r;
                        col_w=max_col_r;// need to update the board with max row,col
                    end

                end
                else begin
                    state_w=TRAVERSE;
                    if(row_r==7) begin // need to change to next col
                        row_w=0;
                        col_w=col_r+1;
                    end
                    else begin
                        row_w=row_r+1;
                        col_w=col_r;
                    end
                end
                // about max
                if(up_flip>0) begin
                    if (current_weight+up_flip>max_score_r) begin
                        max_score_w=current_weight+up_flip;
                        max_row_w=row_r;
                        max_col_w=col_r;
                    end
                    else begin
                        max_score_w=max_score_r;
                        max_row_w=max_row_r;
                        max_col_w=max_col_r;
                    end
                end
                else begin
                        max_score_w=max_score_r;
                        max_row_w=max_row_r;
                        max_col_w=max_col_r;
                end
            end
            else begin //still wait for updater
                    row_w=row_r;
                    col_w=col_r;
                    state_w=CHECK_TRAVERSE;
                    max_score_w=max_score_r;
                    max_row_w=max_row_r;
                    max_col_w=max_col_r;
            end
            
        end
        UPDATE: begin
            done=0;
            row_w=max_row_r;
            col_w=max_col_w;
            if(max_score_r==0) begin
                state_w=DONE;
                up_start=0;
            end 
            else begin
                up_start=1;
                state_w=CHECK_UPDATE;
            end
        end
        CHECK_UPDATE: begin
            done=0;
            up_start=0;
            if(up_done==1) begin
                row_w=row_r;
                col_w=col_r;
                state_w=DONE;
                max_score_w=max_score_r;
                max_row_w=max_row_r;
                max_col_w=max_col_r;
                color_w=color_r;
                for (i=0;i<8;i=i+1) begin
                    for (j=0;j<8;j=j+1) begin
                        board_w[i][j]=up_board[i][j];
                    end
                end

            end
            
            else begin
                row_w=row_r;
                col_w=col_r;
                state_w=CHECK_UPDATE;
                max_score_w=max_score_r;
                max_row_w=max_row_r;
                max_col_w=max_col_r;
                color_w=color_r;
                for (i=0;i<8;i=i+1) begin
                    for (j=0;j<8;j=j+1) begin
                        board_w[i][j]=board_r[i][j];
                    end
                end

            end
        end
        DONE: begin
            done=1;
            up_start=0;
            row_w=row_r;
            col_w=col_r;
            state_w=IDLE;
            max_score_w=max_score_r;
            max_row_w=max_row_r;
            max_col_w=max_col_r;
            color_w=color_r;
            for (i=0;i<8;i=i+1) begin
                for (j=0;j<8;j=j+1) begin
                        board_w[i][j]=board_r[i][j];
                end
            end
            if(max_score_r==0)begin
                cannot_move=1;
            end
            else begin
                cannot_move=0;
            end

        end
        
        default: begin
                row_w=row_r;
                col_w=col_r;
                state_w=IDLE;
                max_score_w=max_score_r;
                max_row_w=max_row_r;
                max_col_w=max_col_r;
                done=0;
                color_w=color_r;
                up_start=0;
                cannot_move=0;
                for (i=0;i<8;i=i+1) begin
                    for (j=0;j<8;j=j+1) begin
                        board_w[i][j]=board_r[i][j];
                    end
                end
                for (i=0;i<8;i=i+1) begin
                    for (j=0;j<8;j=j+1) begin
                        o_updated_board[i][j]=board_r[i][j];
                    end
                end
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        row_r<=0;
        col_r<=0;
        state_r<=IDLE;
        max_score_r<=0;
        max_row_r<=0;
        max_col_r<=0;
        color_r<=0;
        for (k=0;k<8;k=k+1) begin
            for (m=0;m<8;m=m+1) begin
                board_r[k][m]<=0;
            end
        end
    end
    else begin
        row_r<=row_w;
        col_r<=col_w;
        state_r<=state_w;
        max_score_r<=max_score_w;
        max_row_r<=max_row_w;
        max_col_r<=max_col_w;
        color_r<=color_w;
        for(k=0;k<8;k=k+1) begin
            for (m=0;m<8;m=m+1) begin
                board_r[k][m]<=board_w[k][m];
            end
        end
    end
end
always_comb begin
    if(counter_r==63) begin
        counter_w=0;
    end
    else begin
        counter_w=counter_r+1;
    end
end
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        counter_r<=0;
    end
    else begin
        counter_r<=counter_w;
    end
end
endmodule