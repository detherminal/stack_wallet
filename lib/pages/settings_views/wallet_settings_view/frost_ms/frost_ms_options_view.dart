/*
 * This file is part of Stack Wallet.
 *
 * Copyright (c) 2023 Cypher Stack
 * All Rights Reserved.
 * The code is distributed under GPLv3 license, see LICENSE file for details.
 * Generated by Cypher Stack on 2023-05-26
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackwallet/pages/settings_views/wallet_settings_view/frost_ms/frost_participants_view.dart';
import 'package:stackwallet/pages/settings_views/wallet_settings_view/frost_ms/resharing/involved/step_1a/begin_reshare_config_view.dart';
import 'package:stackwallet/pages/settings_views/wallet_settings_view/frost_ms/resharing/involved/step_1b/import_reshare_config_view.dart';
import 'package:stackwallet/pages_desktop_specific/my_stack_view/exit_to_my_stack_button.dart';
import 'package:stackwallet/providers/db/main_db_provider.dart';
import 'package:stackwallet/providers/frost_wallet/frost_wallet_providers.dart';
import 'package:stackwallet/themes/stack_colors.dart';
import 'package:stackwallet/utilities/constants.dart';
import 'package:stackwallet/utilities/text_styles.dart';
import 'package:stackwallet/utilities/util.dart';
import 'package:stackwallet/wallets/isar/models/frost_wallet_info.dart';
import 'package:stackwallet/widgets/background.dart';
import 'package:stackwallet/widgets/conditional_parent.dart';
import 'package:stackwallet/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackwallet/widgets/desktop/desktop_app_bar.dart';
import 'package:stackwallet/widgets/desktop/desktop_scaffold.dart';
import 'package:stackwallet/widgets/rounded_white_container.dart';

class FrostMSWalletOptionsView extends ConsumerWidget {
  const FrostMSWalletOptionsView({
    Key? key,
    required this.walletId,
  }) : super(key: key);

  static const String routeName = "/frostMSWalletOptionsView";

  final String walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConditionalParent(
      condition: Util.isDesktop,
      builder: (child) => DesktopScaffold(
        background: Theme.of(context).extension<StackColors>()!.background,
        appBar: const DesktopAppBar(
          isCompactHeight: false,
          leading: AppBarBackButton(),
          trailing: ExitToMyStackButton(),
        ),
        body: SizedBox(
          width: 480,
          child: child,
        ),
      ),
      child: ConditionalParent(
        condition: !Util.isDesktop,
        builder: (child) => Background(
          child: Scaffold(
              backgroundColor:
                  Theme.of(context).extension<StackColors>()!.background,
              appBar: AppBar(
                leading: AppBarBackButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  "FROST Multisig options",
                  style: STextStyles.navBarTitle(context),
                ),
              ),
              body: child),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 12,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OptionButton(
                  label: "Show participants",
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      FrostParticipantsView.routeName,
                      arguments: walletId,
                    );
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                _OptionButton(
                  label: "Initiate resharing",
                  onPressed: () {
                    // TODO: optimize this by creating watcher providers (similar to normal WalletInfo)
                    final frostInfo = ref
                        .read(mainDBProvider)
                        .isar
                        .frostWalletInfo
                        .getByWalletIdSync(walletId)!;

                    ref.read(pFrostMyName.state).state = frostInfo.myName;

                    Navigator.of(context).pushNamed(
                      BeginReshareConfigView.routeName,
                      arguments: walletId,
                    );
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                _OptionButton(
                  label: "Import reshare config",
                  onPressed: () {
                    // TODO: optimize this by creating watcher providers (similar to normal WalletInfo)
                    final frostInfo = ref
                        .read(mainDBProvider)
                        .isar
                        .frostWalletInfo
                        .getByWalletIdSync(walletId)!;

                    ref.read(pFrostMyName.state).state = frostInfo.myName;

                    Navigator.of(context).pushNamed(
                      ImportReshareConfigView.routeName,
                      arguments: walletId,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RoundedWhiteContainer(
      padding: const EdgeInsets.all(0),
      child: RawMaterialButton(
        // splashColor: Theme.of(context).extension<StackColors>()!.highlight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            Constants.size.circularBorderRadius,
          ),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 20,
          ),
          child: Row(
            children: [
              Text(
                label,
                style: STextStyles.titleBold12(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}