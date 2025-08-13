import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_event.dart';
import 'package:rental_management_system_flutter/features/auth/auth_state.dart';
import 'package:rental_management_system_flutter/features/billing/billings_page.dart';
import 'package:rental_management_system_flutter/features/home/widgets/square_button.dart';
import 'package:rental_management_system_flutter/features/reading/readings_page.dart';
import 'package:rental_management_system_flutter/features/room/rooms_page.dart';
import 'package:rental_management_system_flutter/features/tenants/tenants_page.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/error_widget.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late AuthBloc authBloc;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    authBloc.add(CheckAuthStatus());
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)).then((updated) {
      if (updated == true) {
        authBloc.add(CheckAuthStatus());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final primaryColor = theme.primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: CustomAppBar(title: 'Welcome Admin!', logoutOnBack: true),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Unauthenticated) {
              return buildErrorWidget(context: context, message: state.message);
            }

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor.withValues(alpha: 0.9), primaryColor.withValues(alpha: 0.6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: screenWidth < 600 ? screenWidth : 600),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SquareButton(text: "Rooms", icon: Icons.meeting_room, onTap: () => _navigateToPage(RoomsPage()), color: primaryColor),
                        const SizedBox(height: 20),
                        SquareButton(text: "Tenants", icon: Icons.people, onTap: () => _navigateToPage(TenantsPage()), color: primaryColor),
                        const SizedBox(height: 20),
                        SquareButton(
                          text: "Electric Readings",
                          icon: Icons.flash_on,
                          onTap: () => _navigateToPage(ReadingsPage()),
                          color: primaryColor,
                        ),
                        const SizedBox(height: 20),
                        SquareButton(text: "Billing", icon: Icons.receipt_long, onTap: () => _navigateToPage(BillingsPage()), color: primaryColor),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
