import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_entry.dart';

enum LeaderboardTab { weekly, monthly, allTime }

final leaderboardTabProvider = StateProvider<LeaderboardTab>((ref) => LeaderboardTab.weekly);

final leaderboardEntriesProvider = Provider<List<LeaderboardEntry>>((ref) {
  // Mock data representing the leaderboard
  return [
    LeaderboardEntry(
      id: '1',
      name: 'Minh',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB6P857tzIGnIrfwPVLDWoFSW9C7Rcosr0lu5QMg4hrWthTjPv_-r5l3nORA2_WRWx68Q5cbcG98nepKBP5xB6UWTvR88VWznw7VA02OlvYfiGRTchrzFfD_YhTpSqwNkiZZh-YRjHRTNT8cChh6epIvYgBuU_jnAHofUVuZHS_gRHYccsNc8rNOwcfVTHYjeiwyf-DsayZOLHr9cxrqKAontcejQadSPjOhdGhSS_enkEqy3_ZQB6HHmTuTcpIjNV-Aku6nkbeN2I',
      points: 1500,
      timeTaken: const Duration(minutes: 10),
      rank: 1,
    ),
    LeaderboardEntry(
      id: '2',
      name: 'Lan',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAH1ZImcc5bUZvM4QPDdr_zu2VEfw-9erJK_29uX0z8UOeUVEB75ZVW4fSV8tMi_tuWeIU70tLigwjEwJfrYPnzVIkF_scI_rIQTSXGMmZkqwjwybZpUKgRVYMAWtocdwYftS23QXOzsPrWmSC4jyX9MzvmNcWAD8E1fP7ZqACp4IKMCqKnQ8VAv79lWmBR5AlQRADJJCVH_9154TcCS59RtG_npQ8s-JEN7xDfcjqY9PS3KeIB4HHbE5E_l2RdY5vRYlCZ-lLnOCY',
      points: 1450,
      timeTaken: const Duration(minutes: 12),
      rank: 2,
    ),
    LeaderboardEntry(
      id: '3',
      name: 'Hùng',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD8XphgDeQ7qlprPCSKHLBGK3dwaznd3vNgW2IQF_-OXgKGSNmUD4ds0-mIRB9XPT3Zwj6OcU2dDkQ8ZnXbPwL2ScbLm-XHekSU2ebAiJvXo2eFuuMzW8GzB6YIPtJz_7TZZXSJnZBKdaRvmmM4oiJZA3ej_TagOBVVgCwqJ3fOw7wxsYPZndvfAZfzyrEmMVi7BDYaeqtkuhUMvixzY9yqO0x73dsGVM3M5os46ZcSbHkflad8WL1UUDciWlg5kTFTUo7NbDDw4Dg',
      points: 1400,
      timeTaken: const Duration(minutes: 11),
      rank: 3,
    ),
    LeaderboardEntry(
      id: '4',
      name: 'Quang Hải',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAP2KuLdFY8fpsJPXj0_HR-J8si70X7e8emZRgk67ShUo-03eHyW2GAXXOalYIZ1O4rHQ9rAHpK7w6Nk1TEFgWQrx-322yNW60KPsTSwyzi2g6K4qNF4cJjjKB0yexcAxDAiEccsELNW3TKikve1vb7BrvzLUG0JWZtVjhyLhr5Hp_QPpOod3qowvzmT_dhV6Uh2GICZsJ_Ae78EEE9zTW9CyWuWsIfQCYUZ-mIuBCLzjvZlhkpGbrhzs_XSTZ09q8illmR--GKsJk',
      points: 1380,
      timeTaken: const Duration(minutes: 12, seconds: 30),
      rank: 4,
    ),
    LeaderboardEntry(
      id: '5',
      name: 'Thùy Chi',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAqVJjS2VicQTAxxdZbdO4NIa2TNId8hsfXi8nm-ckzz-xquOEsQoDrdkCdRLsDZUzq0XZHCr4fcTLelh_X-1bb7-mogheKqJz1ZSfBvjv38Ctvu1gQolK-ldVKce8FdemAcvSi9paFJ4YDVlYnvEGDvvEUwT8YY2NZVT1CGSMngknHbkSphpYkAeU5-vCnTh0td0FXrummOV_Ddl377g1p9D-sgD3ZEYHc-WWlPCurH-LBjty8HeW_H5ArVxufL7AHkyUTeZo6BeU',
      points: 1350,
      timeTaken: const Duration(minutes: 14, seconds: 10),
      rank: 5,
    ),
    LeaderboardEntry(
      id: '6',
      name: 'Tuấn Anh',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBQxELLz6MhfZlbH_bHzKVy_rVG4MyXwf7ilFbjeGTUrhZ9zBn9eTRu5m9x706aclne34GpDu46NFxvJqHkQxGicJ2a8zlDZ4N4phVeAC_jxJL4C3bDhsN_GqmR50dshUFe3rHEIPbZmgpJOt44YlyODmUqQn5g1L24RF9vB0zx8kAhwfUGlfUNRYDMXoHwwUj3uVnbZ9ZhMY0eubLRqG37X-nFUCm4eX7Pe6lNDAXgttDFnvceVTdzpyQvxYOaGyzmTVWRv6e7o3Q',
      points: 1320,
      timeTaken: const Duration(minutes: 11, seconds: 45),
      rank: 6,
    ),
    LeaderboardEntry(
      id: 'current',
      name: 'Bạn (Minh Trí)',
      avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAeSTM7dzhmUTX_91-7QYQyonRc4PFtiIi1IEQUce_uBh9uvda5_ZvbiNxyEJprSeAkzrpnOERvaaGMGg2pOS23KIlWxqQXK6I3_Y53sGzd3CYt6YafvkrOv2lO4iO0_3zo8LY4Yf95Mf46cNkTeKaKYaGf4XuPcSwJ34Bgn1jUyATNPA3Y17QD2VPLCGESwz8qW89FP7LEbrdbQ1EBaWOhL4YHhVD5WtorIa1IIK-lil6mFnGLUkzxUoJk5bJMQKksnb0wX39M2jE',
      points: 1290,
      timeTaken: const Duration(minutes: 15),
      rank: 7,
      isCurrentUser: true,
    ),
  ];
});
