import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/home/presentation/manager/home_bloc.dart';
import 'features/home/presentation/manager/home_event.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const EchoNewsApp());
}

class EchoNewsApp extends StatelessWidget {
  const EchoNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<HomeBloc>()..add(FetchTopStories()),
        ),
      ],
      child: MaterialApp(
        title: 'EchoNews',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6600),
            primary: const Color(0xFFFF6600),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}
