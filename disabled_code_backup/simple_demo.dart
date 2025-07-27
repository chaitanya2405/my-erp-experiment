import 'package:flutter/material.dart';
import 'business_template/design_system/business_themes.dart';
import 'business_template/design_system/business_colors.dart';
import 'business_template/design_system/business_typography.dart';
import 'business_template/design_system/business_spacing.dart';
import 'business_template/components/business_card.dart';
import 'business_template/platform/platform_detector.dart';

/// 🎯 **Simple Business Template Demo**
/// 
/// A working demo that showcases the business template components
/// without complex dependencies

void main() {
  runApp(const SimpleBusinessTemplateDemo());
}

class SimpleBusinessTemplateDemo extends StatelessWidget {
  const SimpleBusinessTemplateDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Template Demo',
      theme: BusinessThemes.lightTheme,
      darkTheme: BusinessThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: const SimpleDemoHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimpleDemoHome extends StatelessWidget {
  const SimpleDemoHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BusinessColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text('Business Template Demo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: PlatformResponsiveBuilder(
        builder: (context, platformInfo) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(BusinessSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(context),
                SizedBox(height: BusinessSpacing.large),
                
                // Design System Section
                _buildDesignSystemSection(context),
                SizedBox(height: BusinessSpacing.large),
                
                // Components Section
                _buildComponentsSection(context),
                SizedBox(height: BusinessSpacing.large),
                
                // Platform Info Section
                _buildPlatformInfoSection(context, platformInfo),
                SizedBox(height: BusinessSpacing.large),
                
                // Color Palette Section
                _buildColorPaletteSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return BusinessCard(
      child: Padding(
        padding: EdgeInsets.all(BusinessSpacing.large),
        child: Column(
          children: [
            Icon(
              Icons.business,
              size: 64,
              color: BusinessColors.primaryBlue,
            ),
            SizedBox(height: BusinessSpacing.medium),
            Text(
              'Business Template System',
              style: BusinessTypography.headingLarge(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: BusinessSpacing.small),
            Text(
              'Enterprise-grade UI templates for your ERP system',
              style: BusinessTypography.bodyLarge(context).copyWith(
                color: BusinessColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: BusinessSpacing.medium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatChip('15+', 'Components'),
                _buildStatChip('100+', 'Colors'),
                _buildStatChip('All', 'Platforms'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: BusinessColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: BusinessColors.primaryBlue,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: BusinessColors.primaryBlue.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignSystemSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Design System',
          style: BusinessTypography.headingMedium(context),
        ),
        SizedBox(height: BusinessSpacing.medium),
        Row(
          children: [
            Expanded(
              child: BusinessCard(
                child: Padding(
                  padding: EdgeInsets.all(BusinessSpacing.medium),
                  child: Column(
                    children: [
                      Icon(
                        Icons.palette,
                        color: BusinessColors.primaryBlue,
                        size: 32,
                      ),
                      SizedBox(height: BusinessSpacing.small),
                      Text(
                        'Typography',
                        style: BusinessTypography.titleMedium(context),
                      ),
                      SizedBox(height: BusinessSpacing.small),
                      Text(
                        'Consistent font hierarchy',
                        style: BusinessTypography.bodySmall(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: BusinessSpacing.medium),
            Expanded(
              child: BusinessCard(
                child: Padding(
                  padding: EdgeInsets.all(BusinessSpacing.medium),
                  child: Column(
                    children: [
                      Icon(
                        Icons.space_bar,
                        color: BusinessColors.successGreen,
                        size: 32,
                      ),
                      SizedBox(height: BusinessSpacing.small),
                      Text(
                        'Spacing',
                        style: BusinessTypography.titleMedium(context),
                      ),
                      SizedBox(height: BusinessSpacing.small),
                      Text(
                        'Responsive spacing system',
                        style: BusinessTypography.bodySmall(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComponentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Components',
          style: BusinessTypography.headingMedium(context),
        ),
        SizedBox(height: BusinessSpacing.medium),
        
        // BusinessCard Examples
        BusinessCard(
          variant: BusinessCardVariant.elevated,
          child: Padding(
            padding: EdgeInsets.all(BusinessSpacing.medium),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(BusinessSpacing.medium),
                  decoration: BoxDecoration(
                    color: BusinessColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: BusinessColors.primaryBlue,
                    size: 32,
                  ),
                ),
                SizedBox(width: BusinessSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Elevated Business Card',
                        style: BusinessTypography.titleMedium(context),
                      ),
                      SizedBox(height: BusinessSpacing.small),
                      Text(
                        'Professional card component with elevation and hover effects',
                        style: BusinessTypography.bodySmall(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: BusinessSpacing.medium),
        
        BusinessCard(
          variant: BusinessCardVariant.outlined,
          child: Padding(
            padding: EdgeInsets.all(BusinessSpacing.medium),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(BusinessSpacing.medium),
                  decoration: BoxDecoration(
                    color: BusinessColors.warningOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.outlined_flag,
                    color: BusinessColors.warningOrange,
                    size: 32,
                  ),
                ),
                SizedBox(width: BusinessSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Outlined Business Card',
                        style: BusinessTypography.titleMedium(context),
                      ),
                      SizedBox(height: BusinessSpacing.small),
                      Text(
                        'Clean outlined variant for subtle emphasis',
                        style: BusinessTypography.bodySmall(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformInfoSection(BuildContext context, PlatformInfo platformInfo) {
    return BusinessCard(
      child: Padding(
        padding: EdgeInsets.all(BusinessSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.devices,
                  color: BusinessColors.primaryBlue,
                ),
                SizedBox(width: BusinessSpacing.small),
                Text(
                  'Platform Information',
                  style: BusinessTypography.titleMedium(context),
                ),
              ],
            ),
            SizedBox(height: BusinessSpacing.medium),
            _buildInfoRow('Platform', platformInfo.targetPlatform.toString()),
            _buildInfoRow('Device Type', platformInfo.deviceType.toString()),
            _buildInfoRow('Screen Size', 
              '${platformInfo.screenWidth.toInt()} x ${platformInfo.screenHeight.toInt()}'),
            _buildInfoRow('Is Mobile', platformInfo.isMobile.toString()),
            _buildInfoRow('Is Desktop', platformInfo.isDesktop.toString()),
            _buildInfoRow('Is Web', platformInfo.isWeb.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BusinessSpacing.xSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: BusinessColors.primaryBlue,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPaletteSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Palette',
          style: BusinessTypography.headingMedium(context),
        ),
        SizedBox(height: BusinessSpacing.medium),
        BusinessCard(
          child: Padding(
            padding: EdgeInsets.all(BusinessSpacing.medium),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildColorSwatch('Primary Blue', BusinessColors.primaryBlue),
                    SizedBox(width: BusinessSpacing.small),
                    _buildColorSwatch('Success Green', BusinessColors.successGreen),
                    SizedBox(width: BusinessSpacing.small),
                    _buildColorSwatch('Warning Orange', BusinessColors.warningOrange),
                    SizedBox(width: BusinessSpacing.small),
                    _buildColorSwatch('Danger Red', BusinessColors.dangerRed),
                  ],
                ),
                SizedBox(height: BusinessSpacing.medium),
                Row(
                  children: [
                    _buildColorSwatch('Gray 100', BusinessColors.gray100),
                    SizedBox(width: BusinessSpacing.small),
                    _buildColorSwatch('Gray 300', BusinessColors.gray300),
                    SizedBox(width: BusinessSpacing.small),
                    _buildColorSwatch('Gray 500', BusinessColors.gray500),
                    SizedBox(width: BusinessSpacing.small),
                    _buildColorSwatch('Gray 900', BusinessColors.gray900),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
          SizedBox(height: BusinessSpacing.xSmall),
          Text(
            name,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
