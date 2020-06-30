function e_sq = square_error(a, a_est, e, e_est)
    % square error on the unit sphere
    direction = [cosd(e)*cosd(a); cosd(e)*sind(a); sind(e)];
    direction_est = [cosd(e_est)*cosd(a_est); cosd(e_est)*sind(a_est); sind(e_est)];
    cosine = direction'*direction_est;
    angle = acos(cosine);
    e_sq = (2*sin(angle/2))^2;
end