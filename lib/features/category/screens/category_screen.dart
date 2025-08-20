import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/features/category/controllers/category_controller.dart';
import 'package:sixam_mart_store/features/category/domain/models/category_model.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryModel? categoryModel;
  final bool showBackButton;

  const CategoryScreen({
    super.key,
    required this.categoryModel,
    this.showBackButton = true,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late final bool _isCategory;

  @override
  void initState() {
    super.initState();
    _isCategory = widget.categoryModel == null;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = Get.find<CategoryController>();
      if (_isCategory) {
        await controller.getCategoryList(null);
      } else {
        await controller.getSubCategoryList(widget.categoryModel!.id, null);
      }
    });
  }

  Future<void> _onRefresh() async {
    final controller = Get.find<CategoryController>();
    if (_isCategory) {
      await controller.getCategoryList(null);
    } else {
      await controller.getSubCategoryList(widget.categoryModel!.id, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: _isCategory ? 'categories'.tr : (widget.categoryModel!.name ?? ''),
        isBackButtonExist: widget.showBackButton,
      ),
      body: GetBuilder<CategoryController>(
        builder: (categoryController) {
          List<CategoryModel>? categories;

          if (_isCategory && categoryController.categoryList != null) {
            categories = List<CategoryModel>.from(categoryController.categoryList!);
          } else if (!_isCategory && categoryController.subCategoryList != null) {
            categories = List<CategoryModel>.from(categoryController.subCategoryList!);
          }

          if (categories == null) {
            // لسه بيحمّل
            return const Center(child: CircularProgressIndicator());
          }

          if (categories.isEmpty) {
            return Center(
              child: Text(_isCategory ? 'no_category_found'.tr : 'no_subcategory_found'.tr),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final item = categories![index];
                return InkWell(
                  onTap: () {
                    if (_isCategory) {
                      Get.toNamed(RouteHelper.getSubCategoriesRoute(item));
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      color: Theme.of(context).cardColor,
                      boxShadow: Get.isDarkMode
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.grey[300]!,
                                spreadRadius: 1,
                                blurRadius: 5,
                              )
                            ],
                    ),
                    child: Row(
                      children: [
                        if (_isCategory)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: CustomImageWidget(
                              image: '${item.imageFullUrl}',
                              height: 55,
                              width: 65,
                              fit: BoxFit.cover,
                            ),
                          ),
                        SizedBox(width: _isCategory ? Dimensions.paddingSizeSmall : 0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name ?? '',
                                style: robotoRegular,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              Text(
                                '${'id'.tr}: ${item.id}',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
