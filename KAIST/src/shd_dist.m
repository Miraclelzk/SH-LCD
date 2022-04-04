function [dist] = shd_dist(D1,D2)

    cos_similarity = dot(D1, D2) / (norm(D1)*norm(D2));
    
    dist=1-cos_similarity;

end
