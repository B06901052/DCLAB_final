timeunit		10ns;
timeprecision	10ns;

module updater(
  input   i_clk,
  input   i_rst_n,
  input   i_start,
  input i_color,
  input [2:0] i_row,
  input [2:0] i_col,
  input [1:0] i_current_board [0:7] [0:7],
  output [1:0] o_updated_board [0:7] [0:7],
  output [5:0] o_score [0:1],
  output [4:0] o_flip,
  output o_done
) ;
// this is the module to calculate the number of enemy filpped by move in the given direction
localparam IDLE = 0;
localparam CAL=1;
localparam CHECK_CAL=2;
localparam FLIP = 3;
localparam GRADE = 4;
localparam DONE = 5;
integer i,j;
parameter logic signed [3:0] dir_row [0:7] = '{
  3'b0,-3'b1,-3'b1,-3'b1,3'b0,3'b1,3'b1,3'b1
};
parameter logic signed [3:0] dir_col [0:7] = '{
  3'b1,3'b1,3'b0,-3'b1,-3'b1,-3'b1,3'b0,3'b1
};
logic color_w,color_r;
logic [2:0] row_r,row_w,col_r,col_w; // where we are
logic [1:0] board_r[0:7][0:7];
logic [1:0] board_w[0:7][0:7];
logic [5:0] score_r[0:1]; //output score only used in grade
logic [5:0] score_w[0:1];
logic [5:0] score[0:1];
logic [4:0] total_flip_w,total_flip_r;
logic cal_done, grade_done, all_done;
logic cal_start, grade_start;
logic signed [3:0] dire_row, dire_col;
logic [4:0] cal_num;
logic [3:0] state_w,state_r;
logic [3:0] count8_r,count8_w;
logic [4:0] cal_num_r,cal_num_w;
logic [4:0] flip_count_r,flip_count_w;
logic [2:0] flip_row,flip_col; // position where we flip
logic [1:0] board[0:7][0:7];
assign dire_row=dir_row[count8_r];
assign dire_col=dir_col[count8_r];
assign flip_row=row_r+(flip_count_r*dire_row);
assign flip_col=col_r+(flip_count_r*dire_col);
assign o_done=all_done;
assign o_flip=total_flip_r;
integer n,p,q;
assign o_score[0]=score_r[0];
assign o_score[1]=score_r[1];

calculate_flip flip0(
	.i_clk(i_clk),
	.i_start(cal_start),
    .i_rst_n(i_rst_n),
	.i_dir_row(dire_row),
	.i_dir_col(dire_col),
    .i_board(board_r),
	.i_step_row(row_r),
	.i_step_col(col_r), // you are outputing (you are not outputing only when you are "ack"ing.)
	.i_color(color_r),
    .o_done(cal_done),
    .o_num(cal_num)
);
grade grade0(
  .i_clk(i_clk),
  .i_rst_n(i_rst_n),
  .i_start(grade_start),
  .i_board(board),
  .o_score(score),
  .o_done(grade_done)
) ;
always_comb begin
    for (i=0;i<8;i=i+1) begin
        for(j=0;j<8;j=j+1) begin
        board[i][j]=board_r[i][j];
    end
    end
    for (i=0;i<8;i=i+1) begin
        for(j=0;j<8;j=j+1) begin
            o_updated_board[i][j]=board_r[i][j];
    end
    end
        color_w=color_r;
        row_w=row_r;
        col_w=col_r; // where we are
        for (i=0;i<8;i=i+1) begin
            for(j=0;j<8;j=j+1)
            board_w[i][j]=board_r[i][j];
        end
        for (p=0;p<2;p=p+1) begin
            score_w[p]=score_r[p];
        end
        total_flip_w=total_flip_r;
        all_done=0;
        cal_start=0;
        grade_start=0;
        state_w=state_r;
        count8_w=count8_r;
        cal_num_w=cal_num_r;
        flip_count_w=0;

        case(state_r)
            IDLE: begin
                all_done=0;
                flip_count_w=0;
                if(i_start) begin
                    if (i_current_board[i_row][i_col]==2) begin
                        state_w=CAL;
                    end
                    else begin
                        state_w=GRADE;
                    end
                    color_w=i_color;
                    col_w=i_col;
                    row_w=i_row;
                    for (i=0;i<8;i=i+1) begin
                        for(j=0;j<8;j=j+1)
                        board_w[i][j]=i_current_board[i][j];
                    end
                    for (p=0;p<2;p=p+1) begin
                        score_w[p]=0;
                    end
                    total_flip_w=0;
                    all_done=0;
                    cal_start=0;
                    grade_start=0;
                    count8_w=0;
                    cal_num_w=0;
                end
                else begin
                    state_w=IDLE;
                    color_w=0;
                    col_w=0;
                    row_w=0;
                    for (i=0;i<8;i=i+1) begin
                        for(j=0;j<8;j=j+1)
                        board_w[i][j]=0;
                    end
                    for (p=0;p<2;p=p+1) begin
                        score_w[p]=0;
                    end
                    total_flip_w=0;
                    all_done=0;
                    cal_start=0;
                    grade_start=0;
                    count8_w=0;
                    cal_num_w=0;
                end
            end
            CAL: begin
                all_done=0;
                flip_count_w=0;
                if(cal_done) begin // get information of cal
                    state_w=CHECK_CAL;
                    color_w=color_r;
                    col_w=col_r;
                    row_w=row_r;
                    for (i=0;i<8;i=i+1) begin
                        for(j=0;j<8;j=j+1)
                        board_w[i][j]=board_r[i][j];
                    end
                    for (p=0;p<2;p=p+1) begin
                        score_w[p]=0;
                    end
                    total_flip_w=total_flip_r;
                    all_done=0;
                    cal_start=0;
                    grade_start=0;
                    count8_w=count8_r;
                    cal_num_w=cal_num;// it is from output of cal submodule
                end
                else begin // wait for cal
                    state_w=CAL;
                    color_w=color_r;
                    col_w=col_r;
                    row_w=row_r;
                    for (i=0;i<8;i=i+1) begin
                        for(j=0;j<8;j=j+1)
                        board_w[i][j]=board_r[i][j];
                    end
                    for (p=0;p<2;p=p+1) begin
                        score_w[p]=0;
                    end
                    total_flip_w=total_flip_r;
                    all_done=0;
                    cal_start=1;
                    grade_start=0;
                    count8_w=count8_r;
                    cal_num_w=cal_num_r;
                end
            end
            CHECK_CAL: begin
                all_done=0;
                flip_count_w=0;
                if(cal_num_r>0) begin // go to flip
                    state_w=FLIP;
                    color_w=color_r;
                    col_w=col_r;
                    row_w=row_r;
                    for (i=0;i<8;i=i+1) begin
                        for(j=0;j<8;j=j+1)
                        board_w[i][j]=board_r[i][j];
                    end
                    for (p=0;p<2;p=p+1) begin
                        score_w[p]=0;
                    end
                    total_flip_w=total_flip_r+cal_num_r;
                    all_done=0;
                    cal_start=0;
                    grade_start=0;
                    count8_w=count8_r;
                    cal_num_w=cal_num_r;
                end
                else begin
                    if(count8_r>6) begin //count8=7 no flip so go to grade
                        state_w=GRADE;
                        color_w=color_r;
                        col_w=col_r;
                        row_w=row_r;
                        for (i=0;i<8;i=i+1) begin
                            for(j=0;j<8;j=j+1)
                            board_w[i][j]=board_r[i][j];
                        end
                        for (p=0;p<2;p=p+1) begin
                            score_w[p]=0;
                        end
                        total_flip_w=total_flip_r+cal_num_r;
                        all_done=0;
                        cal_start=0;
                        grade_start=0;
                        count8_w=count8_r;
                        cal_num_w=cal_num_r;    
                    end 
                    else begin // count8<7 no flip go to cal
                        state_w= CAL;
                        color_w=color_r;
                        col_w=col_r;
                        row_w=row_r;
                        for (i=0;i<8;i=i+1) begin
                            for(j=0;j<8;j=j+1)
                            board_w[i][j]=board_r[i][j];
                        end
                        for (p=0;p<2;p=p+1) begin
                            score_w[p]=0;
                        end
                        total_flip_w=total_flip_r+cal_num_r;
                        all_done=0;
                        cal_start=0;
                        grade_start=0;
                        count8_w=count8_r+1;
                        cal_num_w=cal_num_r;
                    end
                end
            end
            FLIP: begin
                all_done=0;
                if(flip_count_r<=cal_num_r) begin // not yet done flipping
                    state_w=FLIP;
                    color_w=color_r;
                    col_w=col_r;
                    row_w=row_r;
                    board_w[flip_row][flip_col]=color_r;
                    for (p=0;p<2;p=p+1) begin
                        score_w[p]=0;
                    end
                    total_flip_w=total_flip_r;
                    all_done=0;
                    cal_start=0;
                    grade_start=0;
                    count8_w=count8_r;
                    cal_num_w=cal_num_r;
                    flip_count_w=flip_count_r+1;
                end
                else begin //done flipping
                    if (count8_r>=7) begin //go to grade
                        state_w=GRADE;
                        color_w=color_r;
                        col_w=col_r;
                        row_w=row_r;
                        for (i=0;i<8;i=i+1) begin
                            for(j=0;j<8;j=j+1)
                            board_w[i][j]=board_r[i][j];
                        end
                        for (p=0;p<2;p=p+1) begin
                            score_w[p]=0;
                        end
                        total_flip_w=total_flip_r;
                        all_done=0;
                        cal_start=0;
                        grade_start=0;
                        count8_w=count8_r;
                        cal_num_w=cal_num_r; 
                        flip_count_w=flip_count_r;   
                    end
                    else begin // go back to cal
                        state_w=CAL;
                        color_w=color_r;
                        col_w=col_r;
                        row_w=row_r;
                        for (i=0;i<8;i=i+1) begin
                            for(j=0;j<8;j=j+1)
                            board_w[i][j]=board_r[i][j];
                        end
                        for (p=0;p<2;p=p+1) begin
                            score_w[p]=0;
                        end
                        total_flip_w=total_flip_r;
                        all_done=0;
                        cal_start=0;
                        grade_start=0;
                        count8_w=count8_r+1;
                        cal_num_w=cal_num_r;
                        flip_count_w=flip_count_r;    
                    end
                end
            end
            GRADE: begin
                all_done=0;
                if (total_flip_r>0) begin
                    board[row_r][col_r]=color_r;
                    board_w[row_r][col_r]=color_r;
                end
                else begin
                    board_w[row_r][col_r]=board_r[row_r][col_r]; 
                end
                if(grade_done) begin //collect information from grade
                        state_w=DONE;
                        color_w=color_r;
                        col_w=col_r;
                        row_w=row_r;
                        for (i=0;i<8;i=i+1) begin
                            for(j=0;j<8;j=j+1)
                            board_w[i][j]=board_r[i][j];
                        end
                        for (p=0;p<2;p=p+1) begin
                            score_w[p]=score[p];
                        end
                        total_flip_w=total_flip_r;
                        all_done=0;
                        cal_start=0;
                        grade_start=0;
                        count8_w=count8_r;
                        cal_num_w=cal_num_r; 
                        flip_count_w=0;   
                end
                else begin
                        state_w=GRADE;
                        color_w=color_r;
                        col_w=col_r;
                        row_w=row_r;
                        for (i=0;i<8;i=i+1) begin
                            for(j=0;j<8;j=j+1)
                            board_w[i][j]=board_r[i][j];
                        end
                        for (p=0;p<2;p=p+1) begin
                            score_w[p]=0;
                        end
                        total_flip_w=total_flip_r;
                        all_done=0;
                        cal_start=0;
                        grade_start=1;
                        count8_w=count8_r;
                        cal_num_w=cal_num_r; 
                        flip_count_w=flip_count_r;   
                end
            end
            DONE: begin
                state_w=IDLE;
                color_w=color_r;
                col_w=col_r;
                row_w=row_r;
                for (i=0;i<8;i=i+1) begin
                    for(j=0;j<8;j=j+1)
                    board_w[i][j]=board_r[i][j];
                end
                for (p=0;p<2;p=p+1) begin
                    score_w[p]=score_r[p];
                end
                total_flip_w=total_flip_r;
                all_done=1;
                cal_start=0;
                grade_start=0;
                count8_w=count8_r;
                cal_num_w=cal_num_r; 
                flip_count_w=0;   
            end
            default: begin
                state_w=IDLE;
            end
        endcase
end
integer k,m;
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        color_r<=0;
        row_r<=0;
        col_r<=0; // where we are
        for (k=0;k<8;k=k+1) begin
            for(m=0;m<8;m=m+1)
            board_r[k][m]<=0;
        end
        for (q=0;q<2;q=q+1) begin
            score_r[q]<=0;
        end
        total_flip_r<=0;
        state_r<=IDLE;
        count8_r<=0;
        cal_num_r<=0;
        flip_count_r<=0;
    end
    else begin
        color_r<=color_w;
        row_r<=row_w;
        col_r<=col_w; // where we are
        for (k=0;k<8;k=k+1) begin
            for(m=0;m<8;m=m+1)
            board_r[k][m]<=board_w[k][m];
        end
        for (q=0;q<2;q=q+1) begin
            score_r[q]<=score_w[q];
        end
        total_flip_r<=total_flip_w;
        count8_r<=count8_w;
        state_r<=state_w;
        cal_num_r<=cal_num_w;
        flip_count_r<=flip_count_w;
    end
end
endmodule