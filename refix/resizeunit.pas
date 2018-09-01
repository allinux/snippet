unit resizeunit;

{ resize bm1 to fit in bm2
  bm1,bm2 bitmaps must be created and width,height set }

interface

uses windows,graphics;

procedure BMresize;

var bm1,bm2 : Tbitmap;

implementation

type PDW = ^dword;

procedure BMresize;
//copy bm1 to bm2
var ps0,pd0,psStep,pdStep : dword;       //scanline[0], row steps
    sx1,sy1,sx2,sy2 : single;             //source field positions
    x,y,i,j,destwidth,destheight : word;  //source,dest field pixels
    destR,destG,destB : single;           //destination colors
    sR,sG,sB : byte;                      //source colors
    fx,fy,fix,fiy,dyf : single;           //factors
    fxstep,fystep, dx,dy : single;
    color : dword;
    pdy,pdx,psi,psj : dword;
    AP : single;
    istart,iend,jstart,jend : word;
    devX1,devX2,devY1,devY2 : single;
begin
 ps0 := DWORD(bm1.scanline[0]);
 psstep := ps0 - DWORD(bm1.scanline[1]);
 pd0 := DWORD(bm2.scanline[0]);
 pdstep := pd0 - DWORD(bm2.scanline[1]);
 destwidth := bm2.Width-1;
 destheight := bm2.Height-1;
 fx := bm1.width/ bm2.width;
 fy := bm1.height/bm2.height;
 fix := 1/fx;
 fiy := 1/fy;
 fxstep := 0.9999 * fx;
 fystep := 0.9999 * fy;
 pdy := pd0;
 for y := 0 to destheight do         //vertical destination pixels
  begin
   sy1 := fy * y;
   sy2 := sy1 + fystep;
   jstart := trunc(sy1);
   jend := trunc(sy2);
   devY1 := 1-sy1+jstart;
   devY2 := jend+1-sy2;
   pdx := pdy;
   for x := 0 to destwidth do        //horizontal destination pixels
    begin
     sx1 := fx * x;                        //x related values are repeated
     sx2 := sx1 + fxstep;                  //for each y and may be placed in
     istart := trunc(sx1);                 //lookup table
     iend := trunc(sx2);                   //...
     devX1 := 1-sx1+istart;                  //...
     devX2 := iend+1-sx2;                  //...
     destR := 0; destG := 0; destB := 0;   //clear destination colors
     psj := ps0-jstart*psStep;
     dy := devY1;
     for j := jstart to jend do  //vertical source pixels
      begin
       if j = jend then dy := dy - devY2;
       dyf := dy*fiy;
       psi := psj + (istart shl 2);
       dx := devX1;
       for i := istart to iend do //horizontal source pixels
        begin
         if i = iend then dx := dx - devX2;
         AP := dx*dyf*fix;
         color := PDW(psi)^;
         sB := color;
         destB := destB + sB*AP;
         sG := color shr 8;
         destG := destG + sG*AP;
         sR := color shr 16;
         destR := destR + sR*AP;
         inc(psi,4);
         dx := 1;
        end;//for i
       dec(psj,psStep);
       dy := 1;
      end;//for j
      sB := round(destB);
      sG := round(destG);
      sR := round(destR);
      color := sB or (sG shl 8) or (sR shl 16);
     PDW(pdx)^ := color;
     inc(pdx,4);
    end;//for x
   dec(pdy,pdstep);
  end;//for y
end;

end.
