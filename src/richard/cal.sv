module calculate_flip(
  input   i_clk,
  input   i_start,
  input   i_rst_n,
  input signed [3:0] i_dir_row,// which direction to calculate
  input signed [3:0] i_dir_col,
  input [1:0] i_board[0:7][0:7],
  input [2:0] i_step_row, //where you want to place your stone
  input [2:0] i_step_col,
  input i_color,
  output  o_done,
  output [4:0] o_num
) ;
// this is the module to calculate the number of enemy filpped by move in the given direction
localparam IDLE = 0;
localparam CAL = 1;
localparam DONE = 2;
/*
logic [1:0] board_w[0:7][0:7] ;
logic [1:0] board_r[0:7][0:7] ;
logic [3:0] dir_col_w,dir_col_r, dir_row_w,dir_row_r;
logic color_w,color_r;
logic done_w, done_r;
*/
logic [4:0] num_w, num_r;
logic signed [3:0] step_row_w,step_row_r,step_col_w,step_col_r;// they are location where i am calculating
logic [1:0] state_w,state_r;
logic done;
assign o_done=done;
assign o_num=num_r;
logic [1:0] i_board_i_step_row_i_step_col;
integer i,j;
assign i_board_i_step_row_i_step_col=i_board[i_step_row][i_step_col];//delete after debugging
always_comb begin
        num_w=num_r;
        step_row_w=step_row_r;
        step_col_w=step_col_r;
        state_w=state_r;
        done=0;
    case(state_r)
        IDLE: begin
            if(i_start) begin
                //if(i_board[i_step_row][i_step_col]==2) begin // there is no stone here, worth calculation
                    state_w=CAL;
                    step_row_w=i_step_row+i_dir_row;
                    step_col_w=i_step_col+i_dir_col;
                //end
                /*
                else begin
                    state_w=DONE;
                    step_col_w=i_step_col+i_dir_col;
                    step_row_w=i_step_row+i_dir_row;
                end
                */

            end
            else begin
                state_w=IDLE;
                step_row_w=0;
                step_col_w=0;
            end
            num_w=0;
            done=0;

        end
        CAL: begin
            done=0;
            if (step_col_r<0||step_row_r<0||step_col_r>7||step_row_r>7) begin // now we are out of the board
                state_w=DONE;
                num_w=0;
            end
            else begin // in the board
                step_row_w=step_row_w+i_dir_row;
                step_col_w=step_col_r+i_dir_col;
                if(i_board[step_row_r][step_col_r]==2) begin // meet nothing
                    num_w=0;
                    state_w=DONE;
                end
                else if(i_board[step_row_r][step_col_r]==i_color) begin // meet our own stone
                    num_w=num_r;
                    state_w=DONE;
                end
                else begin // meet enemy
                    num_w=num_r+1;
                    state_w=CAL;
                end
            end
            
        end
        DONE: begin
            done=1;
            state_w=IDLE;
        end
        default: begin
        num_w=num_r;
        step_row_w=step_row_r;
        step_col_w=step_col_r;
        state_w=state_r;
        done=0;
        end
    endcase
    
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        num_r<=0;
        step_row_r<=0;
        step_col_r<=0;
        state_r<=0;
    end
    else begin
        num_r<=num_w;
        step_row_r<=step_row_w;
        step_col_r<=step_col_w;
        state_r<=state_w;
    end
end
endmodule