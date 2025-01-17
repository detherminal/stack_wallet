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
import 'package:stackwallet/frost_route_generator.dart';
import 'package:stackwallet/pages/settings_views/sub_widgets/settings_list_button.dart';
import 'package:stackwallet/pages/settings_views/wallet_settings_view/frost_ms/frost_participants_view.dart';
import 'package:stackwallet/pages/settings_views/wallet_settings_view/frost_ms/initiate_resharing/initiate_resharing_view.dart';
import 'package:stackwallet/pages_desktop_specific/my_stack_view/exit_to_my_stack_button.dart';
import 'package:stackwallet/providers/db/main_db_provider.dart';
import 'package:stackwallet/providers/frost_wallet/frost_wallet_providers.dart';
import 'package:stackwallet/providers/global/wallets_provider.dart';
import 'package:stackwallet/themes/stack_colors.dart';
import 'package:stackwallet/utilities/assets.dart';
import 'package:stackwallet/utilities/text_styles.dart';
import 'package:stackwallet/utilities/util.dart';
import 'package:stackwallet/wallets/isar/models/frost_wallet_info.dart';
import 'package:stackwallet/wallets/wallet/impl/bitcoin_frost_wallet.dart';
import 'package:stackwallet/widgets/background.dart';
import 'package:stackwallet/widgets/conditional_parent.dart';
import 'package:stackwallet/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackwallet/widgets/desktop/desktop_app_bar.dart';
import 'package:stackwallet/widgets/desktop/desktop_scaffold.dart';
import 'package:stackwallet/widgets/frost_scaffold.dart';
import 'package:stackwallet/widgets/rounded_white_container.dart';

class FrostMSWalletOptionsView extends ConsumerWidget {
  const FrostMSWalletOptionsView({
    super.key,
    required this.walletId,
  });

  static const String routeName = "/frostMSWalletOptionsView";

  final String walletId;

  static const _padding = 12.0;

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
                RoundedWhiteContainer(
                  padding: EdgeInsets.zero,
                  child: SettingsListButton(
                    padding: const EdgeInsets.all(_padding),
                    title: "Show participants",
                    iconAssetName: Assets.svg.peers,
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        FrostParticipantsView.routeName,
                        arguments: walletId,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                RoundedWhiteContainer(
                  padding: EdgeInsets.zero,
                  child: SettingsListButton(
                    padding: const EdgeInsets.all(_padding),
                    title: "Initiate resharing",
                    iconAssetName: Assets.svg.swap2,
                    onPressed: () {
                      // TODO: optimize this by creating watcher providers (similar to normal WalletInfo)
                      final frostInfo = ref
                          .read(mainDBProvider)
                          .isar
                          .frostWalletInfo
                          .getByWalletIdSync(walletId)!;

                      ref.read(pFrostMyName.state).state = frostInfo.myName;

                      Navigator.of(context).pushNamed(
                        InitiateResharingView.routeName,
                        arguments: walletId,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                RoundedWhiteContainer(
                  padding: EdgeInsets.zero,
                  child: SettingsListButton(
                    padding: const EdgeInsets.all(_padding),
                    title: "Import reshare config",
                    iconAssetName: Assets.svg.downloadFolder,
                    iconSize: 16,
                    onPressed: () {
                      // TODO: optimize this by creating watcher providers (similar to normal WalletInfo)
                      final frostInfo = ref
                          .read(mainDBProvider)
                          .isar
                          .frostWalletInfo
                          .getByWalletIdSync(walletId)!;

                      ref.read(pFrostMyName.state).state = frostInfo.myName;

                      final wallet = ref.read(pWallets).getWallet(walletId)
                          as BitcoinFrostWallet;

                      ref.read(pFrostScaffoldArgs.state).state = (
                        info: (
                          walletName: wallet.info.name,
                          frostCurrency: wallet.cryptoCurrency,
                        ),
                        walletId: wallet.walletId,
                        stepRoutes: FrostRouteGenerator.importReshareStepRoutes,
                        parentNav: Navigator.of(context),
                        frostInterruptionDialogType:
                            FrostInterruptionDialogType.resharing,
                        callerRouteName: FrostMSWalletOptionsView.routeName,
                      );

                      Navigator.of(context).pushNamed(
                        FrostStepScaffold.routeName,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
