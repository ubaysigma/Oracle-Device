/**
 * THE INDEX: PRESCRIPT DEVICE
 * 
 * CARA KERJA APLIKASI:
 * 
 * 1. Daily Lock (1x Per Hari)
 *    - Pengguna hanya bisa mengambil 1 preskripsi per hari.
 *    - Sekali diambil, teks disimpan di LocalStorage dan tombol terkunci hingga besok.
 * 
 * 2. Deterministik (Seed Tanggal)
 *    - Kalimat di-generate dari tanggal lokal (YYYY-MM-DD) menggunakan PRNG Mulberry32.
 *    - Menghasilkan preskripsi yang sama persis untuk semua orang di hari yang sama.
 * 
 * 3. Scramble Text & Audio Sync
 *    - Teks muncul dengan animasi dekode karakter acak (bercahaya biru muda / pixel font).
 *    - Suara 'index_message_1.wav' berputar selama animasi, lalu terpotong saat selesai.
 *    - Suara 'index_message_2.wav' berbunyi sebagai tanda preskripsi siap dibaca.
 *    - Audio otomatis mati jika pengguna berpindah tab atau meminimalkan aplikasi.
 */

interface PrescriptDevice {
  date: string;              // YYYY-MM-DD
  prescript: string;         // Perintah tugas harian
  isReceivedToday: boolean;  // Kunci harian (true = tombol terkunci)
}
