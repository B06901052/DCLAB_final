CC:=ncverilog

Imgl: ImgLoader.sv ./tb/ImgLoader_tb.sv ./tb/PipelineCtrl.v ./tb/PipelineTb.v
	$(CC) -c $^ +access+r+define+FSDB

GAME: Controller.sv ./tb/Controller_tb.sv ./richard/AI.sv ./richard/cal.sv ./richard/grade.sv ./richard/updater.sv
	$(CC) $^ +access+r +define+FSDB
Imgs: ImgSender.sv ./tb/ImgSender_tb.sv
	$(CC) $^ +access+r +define+FSDB

.PHONY:clean
clean:
	rm -rf *.log *.fsdb INCA_libs nWaveLog