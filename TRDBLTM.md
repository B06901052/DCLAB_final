# TRDB-LTM
## touch panel
S A2\~A0 MODE SER/DFR_b PD1\~0
* S=1
  * start
* A2~0=
  * 001:x-position 
  * 101:y-position
* MODE=0
  * 0: 12bits resolution
  * 1: 8bits resolution
* SER/DFR_b=0
  * 1:single ended mode
    * noise sensitive
  * 0:differencial mode
    * ratiometric conversion mode
* PD1~0=10

