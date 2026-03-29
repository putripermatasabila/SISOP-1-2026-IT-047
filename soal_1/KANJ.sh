BEGIN {FS=",";choice = ARGV[2];delete ARGV[2]
if (choice != "a" && choice != "b"&& choice != "c" && choice != "d" && choice != "e"){
print"Soal tidak dikenali. Gunakan a,b,c,d atau e."; 
print"Contoh penggunaan: awk -f file.sh data.csv a"}
}

NR > 1 {
if (choice =="a") count++
if (choice =="b") carriage[$4]++
if (choice =="c") {if($2>max) {max =$2;max_name=$1}}
if (choice =="d") { total+=$2; count_person++ }
if (choice =="e") if ($3 =="Business")count_business++
}

END {
if (choice =="a") 
{print "Jumlah seluruh penumpang KANJ adalah ", count, " orang"}
if (choice=="b")
{print"Jumlah gerbong penumpang KANJ adalah",length(carriage)}
if (choice=="c")
{print max_name, "adalah penumpang kereta tertua dengan usia",max,"tahun"}
if (choice =="d")
{printf "Rata-rata usia penumpang adalah %d tahun\n", int(total/count_person + 0.5)}
if (choice=="e")
{print "Jumlah penumpang business class ada", count_business, "orang"}
} 

