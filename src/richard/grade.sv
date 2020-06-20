module grade(
  input   i_clk,
  input   i_rst_n,
  input   i_start,
  input [1:0] i_board [0:7] [0:7],
  output [5:0] o_score [0:1],
  output o_done
) ;
// this is the module to calculate the number black and white stones on the board
localparam IDLE = 0;
localparam GRADE = 1;
localparam DONE = 2;
integer i,j;
logic [5:0] black_grade_w, black_grade_r, white_grade_w, white_grade_r;
logic [2:0] row_w,row_r,col_w,col_r;
logic [1:0] state_w, state_r;
logic done;
assign o_done=done;
assign o_score[1]=black_grade_r;
assign o_score[0]=white_grade_r;

always_comb begin
    black_grade_w=black_grade_r;
    white_grade_w=white_grade_r;
    row_w=row_r;
    col_w=col_r;
    state_w=state_r;
    done=0;
    case(state_r)
        IDLE: begin
            done=0;
            if(i_start) begin
                state_w=GRADE;
                black_grade_w=0;
                white_grade_w=0;
                row_w=0;
                col_w=0;
            end
            else begin
                state_w=IDLE;
                black_grade_w=0;
                white_grade_w=0;
                row_w=0;
                col_w=0;
            end
        end
        GRADE: begin
            done=0;
            if(row_r==7&&col_r==7)  begin
                state_w=DONE;
                row_w=row_r;
                col_w=col_r;
            end
            else begin
                state_w=GRADE;
                if(row_r==7) begin // need to change to next col
                    row_w=0;
                    col_w=col_r+1;
                end
                else begin
                    row_w=row_r+1;
                    col_w=col_r;
                end
            end
            if(i_board[row_r][col_r]==1) begin //it is black
                black_grade_w=black_grade_r+1;
                white_grade_w=white_grade_r;
            end
            else if(i_board[row_r][col_r]==0) begin // it is white
                black_grade_w=black_grade_r;
                white_grade_w=white_grade_r+1;
            end
            else begin // there is no stone
                black_grade_w=black_grade_r;
                white_grade_w=white_grade_r;
            end
        end
        DONE: begin
            black_grade_w=black_grade_r;
            white_grade_w=white_grade_r;
            row_w=row_r;
            col_w=col_r;
            state_w=IDLE;
            done=1;
        end
        
        default: begin
            black_grade_w=black_grade_r;
            white_grade_w=white_grade_r;
            row_w=row_r;
            col_w=col_r;
            state_w=IDLE;
            done=0;
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        black_grade_r<=0;
        white_grade_r<=0;
        row_r<=0;
        col_r<=0;
        state_r<=IDLE;
    end
    else begin
        black_grade_r<=black_grade_w;
        white_grade_r<=white_grade_w;
        row_r<=row_w;
        col_r<=col_w;
        state_r<=state_w;
    end
end
endmodule