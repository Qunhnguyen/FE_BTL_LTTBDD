import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contest.dart';

final contestsProvider = Provider<List<Contest>>((ref) {
  return [
    Contest(
      id: '1',
      title: 'Thi thử THPT Quốc Gia 2024',
      subject: 'Toán Học',
      description: 'Đề số 05',
      durationMinutes: 45,
      status: ContestStatus.live,
      participantAvatars: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCYNGZV39FLLKNBjdZXjz1QqUKH9AU94eeO0tph5NVfZAj3j_c4ILRDzdkCOMebwpy3gPavTnct6tZXPzvuZpne2Rup61_sUMjT7_HeYYbwQMKDWoPDQ5iAtaaSIU102-T5yomMwgdwsTpXRPkzoFxJXxfgvt0p8KihvgLqUzzBCEMM7Pi4FvEnN1JxwxPgczrsaDrFeyd0kaC3idHd2qcbyXS-l_frmF8ejFbyANTMnaHxF5R4j9A4keFDeVZHlKk8DsgjFwsd7Ug',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD2JrnTasQhEtMRQaC23lzb7Yzyi_5WXquvgyC4lQoxwkUAxkdnr5v9wh0L1ihPxa7ed3_dsVZNmrJtgj2vqufjW-HWfvnZzt8IILkSeZdFW8a2OfSO68H4I_R2OLctY3Ou3ZfYlJkbis3JIYud2BJZLCapYn2YI-q1zjuuJVSHNaWJ0r38ZernaQmBrQwbz95xCa2-k8LpIhbxD_I65f0IEU250F4QDj2ja348oWm015hexLLayilVcFR9kYCJyCT1EojgLDSIxyQ',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDYZCddu1hbbl-fjP8qrI6XvYJ6eHGHDhgOS0Tw2uonVaebdlGjJ-iUFdQIMY3BEKKbWwXoif_kDSOPuGR1rx-gn9Yex60JgtnA3tJl41-s6oMpRVHPA-FluXjNCPmEwuN2Ep4VtNXtN7Lpc7HeS0IP4vSg5UKqzwa_qaUj5D9fc5loM2009xhQKGzFTKmC_bZBhtenDJ7FqjhL66gV_0yd6AvSfx2qJrzctI-IPZ2fqXDUSOiIRqXbna-_YfmuaAAGyMUJJBoOmjI',
      ],
      totalParticipants: 128,
    ),
    Contest(
      id: '2',
      title: 'Olympic Tiếng Anh Sinh viên',
      subject: 'Tiếng Anh',
      description: 'Vòng loại',
      durationMinutes: 60,
      status: ContestStatus.upcoming,
      startTime: DateTime.now().add(const Duration(hours: 2)),
    ),
    Contest(
      id: '3',
      title: 'Kiểm tra Logic & IQ',
      subject: 'Tư duy logic',
      description: 'Đề tổng hợp',
      durationMinutes: 30,
      status: ContestStatus.live,
      participantAvatars: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBXYLpIl0kW3YdWiEeblARFynrbWKFVCmPizYAY-y0ZrCqKPEASf6iA6H9ZVxezc-9ZxBWKNtsWrpZ_kOABz230JVtgNDyJDdc2wMlUzIhNG4jyErL4GbgRTldc9m9Cm7Cmwcn92iKE7MdVw9yq6oPAilsqun0npZ_aFXF5TpcOQC0tKYjJ-OY-hDk5RqRJlHCDFN82dsrn1aeY_tegMK9MXtUZStFN47BEVaWjPy53gR1-prBkH9CCVmngdL-qJIQ16xci_BjYQnU',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBOG6rLJHgEXef_I878RubWzLysQ7ELAphjXuPzfLaQMUbK5MygnT0eeIOXZIaeW8uJYJ8EV5NpHZncdPWaZVD_970r72IEBBZQm5Hjdm_o1iFMmMNEWkzwJafJvIgaCg2Ky2Uq74XhptalvRJkrJrs22I_EDUrV2sCJLPTY89xINsLpGzpmftUeX-77oTnfNK9g6ucFNX1SgV3mMJraFi2QvIrf8HDYulr8RclF0W7h5zIZGwqgXN9vezzDOXtNWlENNkSbBLAo3U',
      ],
      totalParticipants: 85,
    ),
    Contest(
      id: '4',
      title: 'Lập trình C++ cơ bản',
      subject: 'Lập trình',
      description: 'Kiểm tra giữa kỳ',
      durationMinutes: 90,
      status: ContestStatus.finished,
    ),
  ];
});

final contestStatusFilterProvider = StateProvider<ContestStatus>((ref) => ContestStatus.live);

final filteredContestsProvider = Provider<List<Contest>>((ref) {
  final filter = ref.watch(contestStatusFilterProvider);
  final contests = ref.watch(contestsProvider);
  return contests.where((c) => c.status == filter).toList();
});
