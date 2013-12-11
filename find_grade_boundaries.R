grades = c('A', 'B', 'C', 'D', 'F');
gpas = as.numeric(c(4, 3, 2, 1, 0));
data = read.csv('~/Documents//Berkeley/Fall 2013//CS169/grades/output/final_grades.csv');
hist(data$Total);

model = kmeans(data$Total, length(grades));
centers = model$centers[order(model$centers,decreasing=TRUE),];
centers = cbind(centers, grades, gpas);
centers = centers[order(as.numeric(rownames(centers))),];
centers = as.data.frame(centers);

gpa_freqs = as.numeric(as.character(centers$gpas));
avg_gpa = sum(model$size * gpa_freqs) / nrow(data);