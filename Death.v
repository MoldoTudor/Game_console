`timescale 1ns / 1ps



module Death(
    input clk,
    input [9:0] Coloana,
    input [9:0] Linie,
    input InDisplay,
    input VS,
    output reg [3:0] red,
    output reg[3:0] green,
    output reg [3:0] blue);
    
    localparam HS_min = 144 ; // primul pixel de pe coloana
    localparam HS_max = 783 ; // ultimul pixel de pe coloana
    localparam VS_min = 32; // Prima linie cu output
    localparam VS_max = 511; // ultima linie cu output
    localparam G_stop_l=192;
    localparam G_stop_c=303;
    localparam A_stop_c=463;
    localparam M_stop_c=623;
    localparam E_stop_c=783;
    localparam O_stop_l=352;
    localparam Prima_5=272;
    localparam Doi_5=400;
    localparam Trei_5=528;
    localparam Patru_5=656;
    
    wire G_space ;
    wire A_space;
    wire M_space;
    wire E_space;
    wire O_space;
    wire V_space;
    wire R_space;
    wire E_up;
    wire E_down;
    wire E_middle;
    wire E_down_second;
    reg White ;
    reg [31:0] actual ; 
    reg [6:0] count ; 
    reg [3:0] intensitate=15;
    reg direction ;
    
    
    reg [31:0] memG [0:31]; // memorie pt litera G
    reg [31:0] memA [0:31]; // memorie pt litera A
    reg [31:0] memM [0:31]; // memorie pt litera M
    reg [31:0] memE [0:31]; // memorie pt litera E
    reg [31:0] memO [0:31]; // memorie pt litera O
    reg [31:0] memV [0:31]; // memorie pt litera V
    reg [31:0] memR [0:31]; // memorie pt litera R
    reg [31:0] memN [0:31]; // memorie pt litera R
    reg [31:0] memT [0:31]; // memorie pt litera R
    
    initial begin  // incarcarea memoriilor cu mem
    $readmemb("G.mem",memG);
    $readmemb("A.mem",memA);
    $readmemb("M.mem",memM);
    $readmemb("E.mem",memE);
    $readmemb("O.mem",memO);
    $readmemb("V.mem",memV);
    $readmemb("R.mem",memR);
    $readmemb("N.mem",memN);
    $readmemb("T.mem",memT);
    end
    // Vedem in ce zona suntem
    assign G_space = (Linie>=VS_min)&&(Linie<G_stop_l)&&(Coloana>=HS_min)&&(Coloana<G_stop_c)&&(InDisplay) ; 
    assign A_space = (Linie>=VS_min)&&(Linie<G_stop_l)&&(Coloana>=G_stop_c)&&(Coloana<A_stop_c)&&(InDisplay) ;
    assign M_space = (Linie>=VS_min)&&(Linie<G_stop_l)&&(Coloana>=A_stop_c)&&(Coloana<M_stop_c)&&(InDisplay);
    assign E_up = (Linie>=VS_min)&&(Linie<G_stop_l)&&(Coloana>=M_stop_c)&&(Coloana<HS_max)&&(InDisplay) ;
    assign E_middle = (Linie>=G_stop_l)&&(Linie<O_stop_l)&&(Coloana>=A_stop_c)&&(Coloana<M_stop_c)&&(InDisplay);
    assign E_down = (Linie>=O_stop_l)&&(Linie<VS_max)&&(Coloana>=HS_min)&&(Coloana<Prima_5)&&(InDisplay);
    assign E_down_second = (Linie>=O_stop_l)&&(Linie<VS_max)&&(Coloana>=Trei_5)&&(Coloana<Patru_5)&&(InDisplay);
    assign E_space = E_middle|| E_up || E_down|| E_down_second ;
    assign O_space = (Linie>=G_stop_l)&&(Linie<O_stop_l)&&(Coloana>=HS_min)&&(Coloana<G_stop_c)&&(InDisplay) ; 
    assign V_space = (Linie>=G_stop_l)&&(Linie<O_stop_l)&&(Coloana>=G_stop_c)&&(Coloana<A_stop_c)&&(InDisplay) ;
    assign R_space = ((Linie>=G_stop_l)&&(Linie<O_stop_l)&&(Coloana>=M_stop_c)&&(Coloana<HS_max)&&(InDisplay)||(Linie>=O_stop_l)&&(Linie<VS_max)&&(Coloana>=Patru_5)&&(Coloana<HS_max)&&(InDisplay)) ;
    assign N_space = (Linie>=O_stop_l)&&(Linie<VS_max)&&(Coloana>=Prima_5)&&(Coloana<Doi_5)&&(InDisplay) ;
    assign T_space = (Linie>=O_stop_l)&&(Linie<VS_max)&&(Coloana>=Doi_5)&&(Coloana<Trei_5)&&(InDisplay) ;
    
    always@(posedge clk)
    if(Linie<O_stop_l)
     White<=actual[31-(Coloana-HS_min)/5]&&(InDisplay);  
    else
    White<=actual[31-(Coloana-HS_min)/4]&&(InDisplay);
    
    always@(posedge clk)  // actualizam reg in care stocam informatiile pt zona in care suntem
    if(G_space)
    actual<=memG[(Linie-VS_min)/5] ;
    else
    if(A_space)
    actual<=memA[(Linie-VS_min)/5] ;
    else
    if(M_space)
    actual<=memM[(Linie-VS_min)/5] ;
    else
    if(E_space)
    actual<=memE[(Linie-VS_min)/5] ;
    else
    if(V_space)
    actual<=memV[(Linie-VS_min)/5] ;
    else
    if(O_space)
    actual<=memO[(Linie-VS_min)/5] ;
    else
    if(R_space)
    actual<=memR[(Linie-VS_min)/5] ;
    else
    if(T_space)
    actual<=memT[(Linie-VS_min)/5] ;
    else
    if(N_space)
    actual<=memN[(Linie-VS_min)/5] ;

    
     // Daca bit din bitmap corespunzator e 1 , output e alb   
    always@(posedge clk)
    if(White) begin
        if(Linie>=O_stop_l) begin
            red<=intensitate;
            green<=intensitate;
            blue<=intensitate;
        end
        else begin
            red<=4'b1111;
            green<=4'b1111;
            blue<=4'b1111;
        end
        
    end
    else begin
        red<=4'b0000;
        green<=4'b0000;
        blue<=4'b0000;
    end
    
    always@(negedge VS)
    if(count==6) begin
        if(direction==0) begin
        intensitate<=intensitate-1;
        count<=0;
        end
        else begin
        intensitate<=intensitate+1;
        count<=0;
        end
        end
     else
     count<=count+1;
        
     always@(negedge VS)
     if(intensitate<=6) 
     direction<=1;
     else
     if(intensitate>=14)
     direction<=0;
        
    endmodule
    
    
    
    
    
