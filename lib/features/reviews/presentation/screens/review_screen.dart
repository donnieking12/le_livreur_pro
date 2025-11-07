import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ReviewScreen extends StatefulWidget {
  final String orderId;
  final String? restaurantId;
  final String? courierId;

  const ReviewScreen({
    super.key,
    required this.orderId,
    this.restaurantId,
    this.courierId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Restaurant review
  int _restaurantRating = 0;
  final _restaurantCommentController = TextEditingController();
  
  // Delivery review
  int _deliveryRating = 0;
  final _deliveryCommentController = TextEditingController();
  
  // Overall experience
  int _overallRating = 0;
  final _overallCommentController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _restaurantCommentController.dispose();
    _deliveryCommentController.dispose();
    _overallCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('leave_review'.tr()),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'restaurant'.tr(), icon: const Icon(Icons.restaurant)),
            Tab(text: 'delivery'.tr(), icon: const Icon(Icons.delivery_dining)),
            Tab(text: 'overall'.tr(), icon: const Icon(Icons.star)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRestaurantReview(),
          _buildDeliveryReview(),
          _buildOverallReview(),
        ],
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildRestaurantReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'rate_restaurant'.tr(),
            'how_was_food_quality'.tr(),
            Icons.restaurant_menu,
          ),
          const SizedBox(height: 20),
          _buildStarRating(
            rating: _restaurantRating,
            onRatingChanged: (rating) {
              setState(() {
                _restaurantRating = rating;
              });
            },
          ),
          const SizedBox(height: 30),
          _buildQuickOptions(
            'food_quality'.tr(),
            [
              'excellent_quality'.tr(),
              'good_taste'.tr(),
              'hot_fresh'.tr(),
              'correct_order'.tr(),
              'good_portions'.tr(),
              'cold_food'.tr(),
              'wrong_order'.tr(),
              'poor_quality'.tr(),
            ],
            _restaurantCommentController,
          ),
          const SizedBox(height: 20),
          _buildCommentField(
            'restaurant_comment'.tr(),
            'tell_us_about_food'.tr(),
            _restaurantCommentController,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'rate_delivery'.tr(),
            'how_was_delivery_service'.tr(),
            Icons.delivery_dining,
          ),
          const SizedBox(height: 20),
          _buildStarRating(
            rating: _deliveryRating,
            onRatingChanged: (rating) {
              setState(() {
                _deliveryRating = rating;
              });
            },
          ),
          const SizedBox(height: 30),
          _buildQuickOptions(
            'delivery_service'.tr(),
            [
              'fast_delivery'.tr(),
              'polite_courier'.tr(),
              'on_time'.tr(),
              'careful_handling'.tr(),
              'easy_contact'.tr(),
              'late_delivery'.tr(),
              'rude_courier'.tr(),
              'difficult_to_find'.tr(),
            ],
            _deliveryCommentController,
          ),
          const SizedBox(height: 20),
          _buildCommentField(
            'delivery_comment'.tr(),
            'tell_us_about_delivery'.tr(),
            _deliveryCommentController,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'overall_experience'.tr(),
            'rate_entire_experience'.tr(),
            Icons.star,
          ),
          const SizedBox(height: 20),
          _buildStarRating(
            rating: _overallRating,
            onRatingChanged: (rating) {
              setState(() {
                _overallRating = rating;
              });
            },
          ),
          const SizedBox(height: 30),
          _buildReviewSummary(),
          const SizedBox(height: 20),
          _buildCommentField(
            'additional_comments'.tr(),
            'anything_else_to_share'.tr(),
            _overallCommentController,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating({
    required int rating,
    required ValueChanged<int> onRatingChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingChanged(index + 1),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              index < rating ? Icons.star : Icons.star_outline,
              color: index < rating ? Colors.amber : Colors.grey,
              size: 36,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuickOptions(
    String title,
    List<String> options,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return GestureDetector(
              onTap: () => _addQuickOption(option, controller),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommentField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'review_summary'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.restaurantId != null)
            _buildSummaryRow('restaurant'.tr(), _restaurantRating),
          if (widget.courierId != null)
            _buildSummaryRow('delivery'.tr(), _deliveryRating),
          _buildSummaryRow('overall'.tr(), _overallRating),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label),
          ),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_outline,
                color: index < rating ? Colors.amber : Colors.grey,
                size: 16,
              );
            }),
          ),
          const SizedBox(width: 8),
          Text('($rating/5)'),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _overallRating > 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: canSubmit && !_isSubmitting ? _submitReview : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'submit_review'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _addQuickOption(String option, TextEditingController controller) {
    final currentText = controller.text;
    if (currentText.isEmpty) {
      controller.text = option;
    } else if (!currentText.contains(option)) {
      controller.text = '$currentText, $option';
    }
  }

  Future<void> _submitReview() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Submit review to backend
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('review_submitted_successfully'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_submitting_review'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}