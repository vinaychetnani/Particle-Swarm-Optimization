function [ A2comp ] = MinMaxCheck( minimum, maximum, A2comp)

%%
% function [ A2comp ] = MinMaxCheck( minimum, maximum, A2comp )
% A2comp is the array to check
% minimum and maximum are arrays which holds the minimum and maximum value of each element of an array (A2comp) respectively
% output returns the array where all values within the range
% if element of A2comp is less than minimum boundary value then it's changed to minimum boundary value
% if element of A2comp is greater than maximum boundary value then it's changed to maximum boundary value
%
% all array must be same in length


if nargin < 3
    error('Missing input parameter(s)!')
end

if (length(minimum(:))==length(maximum(:)) && length(maximum(:))==length(A2comp(:)))
    
    size=length(minimum);
    for l=1:size
        if maximum(l)<minimum(l)
            error('Maximum value must be greater than minimum value !!')
        end
    end
    
    for l=1:size
        if(maximum(l)<A2comp(l)||minimum(l)>A2comp(l))
            if(maximum(l)<A2comp(l))
                A2comp(l)=maximum(l);
            else A2comp(l)=minimum(l);
            end
        end
    end
else
    error('All arrays must be same in length...')
end