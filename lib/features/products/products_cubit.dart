import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ProductsStatus { loading, ready, error }

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ProductsStatus.loading,
    this.products = const [],
    this.error = '',
  });

  final ProductsStatus status;
  final List<ApiProduct> products;
  final String error;

  @override
  List<Object?> get props => [status, products, error];
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._repo) : super(const ProductsState());

  final ProductAdminRepository _repo;

  Future<void> load() async {
    emit(const ProductsState());
    try {
      emit(ProductsState(
          status: ProductsStatus.ready, products: await _repo.list()));
    } catch (e) {
      emit(ProductsState(status: ProductsStatus.error, error: '$e'));
    }
  }
}
