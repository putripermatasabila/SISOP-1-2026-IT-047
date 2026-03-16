BEGIN {FS=","}NR>1 {count++} 
END {print "Jumlah seluruh penumpang KANJ adalah ", count, " orang"} 

BEGIN {FS=","} NR>1 {carriage[$4]++} 
END {print"Jumlah gerbong penumpang KANJ adalah",length(carriage)} 

BEGIN{FS=","}NR>1{if($2>max) {max =$2;max_name=$1}}END {print max_name, "adalah penumpang kereta tertua dengan usia", max, " tahun"}

BEGIN {FS=","} NR>1 { total+=$2; count_person++ } 
END {print "Rata-rata usia penumpang adalah",total/count_person, "tahun" }

BEGIN {FS=","} NR>1 && /Business/ {++count_business} 
END {print "Jumlah penumpang business class ada", count_business}
