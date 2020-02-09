enum CheckedItemState { checked, unchecked }

extension CheckedItemStateBool on CheckedItemState {

  bool get isChecked {
    if (this == CheckedItemState.checked) {
      return true;

    } else {
      return false;
    }
  }
}