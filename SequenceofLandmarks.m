%extract the sequence of landmarks
%from each class extract two landmarks
Seq1 = [0,0,0,0,7,7,6,7,6,6,6,6,5,6,5,5,5,5,4,5,4,4,3,4,3,3,3,2,2,2,1,1,1,2,2,2,1,1,1];
Seq2 = [0,0,7,7,6,6,6,6,6,5,6,5,5,5,5,5,4,3,4,3,3,2,2,2,2,1,1,1,1,1,1,1,1,1];
Seq3 = [6,6,6,6,6,6,6,6,6,6];
Seq4 = [5,6,5,5,6,5,5,5,6];
Seq5 = [0,0,7,0,7,7,6,6,6,6,6,5,6,6,5,6,6,6,4,4,3,2,2,1,0,0,0,7,0,7,7,7,0,0];
Seq6 = [0,7,7,6,6,5,6,6,5,6,5,5,6,4,4,4,4,5,5,4,2,1,1,7,0,0,0,0,7];
Seq7 = [0,0,0,7,0,0,7,6,5,5,5,5,5,4,4,0,0,7,7,6,5,5,5,5,5,4,4,4,3,4,4,3];
Seq8 = [0,7,7,6,5,5,6,4,4,5,4,4,0,0,1,0,0,7,7,6,6,5,6,5,4,5,5,5,4,5,4,5];
Seq9 = [6,5,7,6,4,5,6,5,0,0,7,0,7,6,5,6,6,6,6,5,6,5,6,5,5,6,5,6,5,6];
Seq10 = [5,5,6,5,7,0,7,7,0,1,1,1,0,0,0,4,5,6,5,5,6,6,6,6,6,5,5,5,6,5,5,6,5];
Seq11 = [0,0,0,0,1,1,5,4,5,7,7,7,7,7,6,5,6,5,5,5,4,4,3,4,4,3,4,3,2];
Seq12 = [0,1,0,1,0,0,0,0,0,1,0,0,6,0,7,0,7,7,6,5,5,4,4,4,4,4,3,3,2,1,1,1];
Seq13 = [4,5,6,6,5,5,6,6,5,6,5,5,6,6,7,7,7,0,0,1,1,1,1,2,1,5,6,5,5,5,5];
Seq14 = [5,5,5,6,5,6,5,5,6,5,6,6,6,7,7,7,0,1,0,0,1,1,1,0,4,5,5,5];
Seq15 = [2,1,1,0,7,0,0,7,7,6,6,5,6,5,5,6,5,6,5,5,5,6,5,4];
Seq16 = [0,1,0,1,0,1,0,7,1,0,6,6,6,6,5,6,6,5,6,6,6,6,6,5,6];
Seq17 = [5,5,5,5,5,7,6,7,7,7,6,5,5,5,4,4,4,4,3,2,2,1,1,1,1,2,1,1,1,1,1,1,0,1,1,0];
Seq18 = [5,6,5,5,6,6,7,6,6,0,6,6,7,6,5,6,6,5,4,4,4,4,3,2,2,1,1,1,1,1,0,1,0,1,1,1,1,1,2,3,3,4,4,4,4];
Seq19 = [4,5,4,5,6,5,6,6,6,7,7,0,0,0,1,1,1,2,2,3,2,3,3,6,6,6,6,6,6,6,6];
Seq20 = [4,4,4,5,5,5,5,6,6,7,7,0,0,0,0,1,1,1,2,2,2,3,3,6,5,5,5,5,6];
Sequences = cell(1,20);
for i = 1:20,
    index = strcat('Seq',num2str(i));
    Sequences{1,i} = eval(index);
end
    


