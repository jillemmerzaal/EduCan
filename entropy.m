function [out] = entropy(data)
    pd = fitdist(data,'kernel','Kernel','normal');
    pi = pdf(pd,data);
    temp = pi.*log(pi);
    out=-sum(temp);
    